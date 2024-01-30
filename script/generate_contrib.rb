# frozen_string_literal: true

# Usage: ruby script/generate_contrib.rb 16.1 15.5 14.9 13.9

require 'yaml'
require 'fileutils'
require 'active_support'
require 'active_support/core_ext/hash/keys'

def detect_slug(dir, ext)
  slug = ext.gsub('_', '-')
  return slug if try_slug(dir, slug)

  slug = ext.gsub('_', '')
  return slug if try_slug(dir, slug)

  ext
end

def try_slug(dir, ext)
  return true if File.exist?("#{dir}/#{ext}.html")

  false
end

def parse_readme(html_dir, slug)
  html = `lynx -dump #{html_dir}/#{slug}.html`
  html.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').gsub(/References.*/m, '')
end

def generate_buildkits(dirs)
  buildkits = {}

  dirs.each do |dir|
    Dir["#{dir}/**/*.control"].each do |file|
      content = File.read(file)
      html_dir = "#{dir}/../doc/src/sgml/html"

      comment = content.match(/^comment = '(.*)'/)
      raise "Unable to parse comment from #{file}" if comment.nil?

      requires = content.match(/^requires = '(.*)'/)
      # ignore contribs that has dependencies
      next unless requires.nil?

      version = file.match(/postgresql-(\d+)\.(\d+)/)
      raise "Unable to parse version from #{file}" if version.nil?

      ext_dir = File.dirname(file).split('/').last
      description = comment[1]
      pg_major = version[1]
      pg_minor = version[2]
      ext = File.basename(file, '.control')
      slug = detect_slug(html_dir, ext)
      readme = <<~README
        For formatted documentation, please see https://www.postgresql.org/docs/#{pg_major}/#{slug}.html.

        ```
        #{parse_readme(html_dir, slug)}
        ```
      README

      buildkit = buildkits[ext]
      if buildkit.nil?
        buildkit = {
          apiVersion: 'v1',
          name: ext,
          repository: 'https://github.com/postgres/postgres',
          description:,
          license: 'PostgreSQL',
          arch: %w[amd64 arm64],
          maintainers: [
            {
              name: 'Jonathan Dance',
              email: 'jd@hydra.so'
            },
            {
              name: 'Owen Ou',
              email: 'o@hydra.so'
            }
          ],
          build: {
            main: [{
              name: "Build #{ext}",
              run: <<~SHELL
                cd contrib/#{ext_dir}
                make USE_PGXS=1
                DESTDIR=${DESTDIR} make USE_PGXS=1 install
              SHELL
            }]
          },
          overrides: {
            pgVersions: {}
          },
          pgVersions: []
        }

        buildkits[ext] = buildkit
      end

      buildkit[:pgVersions] << pg_major
      buildkit[:overrides][:pgVersions][pg_major] = {
        source: "https://ftp.postgresql.org/pub/source/v#{pg_major}.#{pg_minor}/postgresql-#{pg_major}.#{pg_minor}.tar.gz",
        version: "#{pg_major}.#{pg_minor}.0",
        homepage: "https://www.postgresql.org/docs/#{pg_major}/#{slug}.html",
        readme:
      }
    end
  end

  buildkits
end

def download_pg(ver)
  return if Dir.exist?("tmp/postgresql-#{ver}")

  puts `wget -P tmp "https://ftp.postgresql.org/pub/source/v#{ver}/postgresql-#{ver}.tar.gz"`
  puts `tar -xvf tmp/postgresql-#{ver}.tar.gz -C tmp`
end

FileUtils.mkdir_p 'tmp'
ARGV.each do |arg|
  download_pg(arg)
end

dirs = ARGV.map { "tmp/postgresql-#{_1}/contrib" }
buildkits = generate_buildkits(dirs)

FileUtils.mkdir_p 'contrib'
buildkits.each do |ext, buildkit|
  File.write("contrib/#{ext.gsub('-', '_')}.yaml", buildkit.deep_stringify_keys.to_yaml)
end
