require 'git'
require 'parse_a_changelog'

RSpec.describe 'a published gem' do # rubocop:disable RSpec/DescribeClass
  def get_version(git, branch = 'HEAD')
    git.grep('VERSION = ', 'lib/*/version.rb', { object: branch }).
      map { |_sha, matches| matches.first[1] }.
      filter_map { |str| parse_version(str) }.
      first
  rescue Git::GitExecuteError
    # Catches failures for branch name being master
    nil
  end

  def parse_version(string)
    string.match(/VERSION = ['"](.*)['"]/)[1]
  end

  def main_branch
    @main_branch ||=
      if git.branches['origin/main']
        'origin/main'
      elsif git.branches['origin/master']
        'origin/master'
      else
        raise StandardError,
          <<~ERROR
            Couldn't determine main branch.
            Does 'origin/main' or 'origin/master' need to be fetched?
          ERROR
      end
  end

  def needs_version_bump?
    base = git.merge_base(main_branch, 'HEAD').first&.sha
    base ||= main_branch
    git.diff(base, 'HEAD').any? { |diff|
      not_gemfile?(diff) && not_dotfile?(diff) && not_docs?(diff) && not_spec?(diff)
    }
  end

  def not_gemfile?(diff)
    ['Gemfile', 'Gemfile.lock'].exclude?(diff.path)
  end

  def not_docs?(diff)
    !diff.path.end_with?('.md')
  end

  def not_spec?(diff)
    !diff.path.start_with?('spec/')
  end

  def not_dotfile?(diff)
    # Ignore dotfiles, like .gitignore and CI files like .github/...
    !diff.path.start_with?('.')
  end

  let(:git) { Git.open('.') }
  let(:head_version) { get_version(git, 'HEAD') }

  it 'has a version number' do
    expect(head_version).not_to be_nil
  end

  it 'has a bumped version committed' do
    main_version = get_version(git, main_branch)
    skip('first time publishing, no need to compare versions') if main_version.nil?

    is_main_branch = git.current_branch == main_branch
    skip('already on main branch, no need to compare versions') if is_main_branch

    skip('Diff only contains non-code changes, no need to bump version') unless needs_version_bump?

    expect(Gem::Version.new(head_version)).to be > Gem::Version.new(main_version)
  end

  it 'has a CHANGELOG.md file' do
    expect(File).to exist('CHANGELOG.md')
  end

  it 'has changelog entry for current version' do
    parser = ParseAChangelog.parse('CHANGELOG.md')
    versions = parser.elements[2].elements.map { |element| element.elements[1].text_value }
    expect(versions.first).to include(head_version)
  end
end
