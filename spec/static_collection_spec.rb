require 'git'

describe StaticCollection do
  def get_version(git, branch = 'HEAD')
    git.grep('VERSION = ', 'lib/*/version.rb', { object: branch }).
      map { |_sha, matches| matches.first[1] }.
      filter_map { |version_string| parse_version(version_string) }.
      first
  end

  def parse_version(string)
    string.match(/VERSION = ['"](.*)['"]/)[1]
  end

  it 'has a version number' do
    git = Git.open('.')
    head_version = get_version(git, 'HEAD')
    expect(head_version).not_to be_nil
  end

  it 'has a bumped version' do
    git = Git.open('.')
    main_version = get_version(git, 'main')
    skip('first time publishing, no need to compare versions') if main_version.nil?

    is_main_branch = git.current_branch == 'main'
    skip('already on main branch, no need to compare versions') if is_main_branch

    head_version = get_version(git, 'HEAD')
    raise 'no version.rb file found on the current branch' if head_version.nil?

    expect(Gem::Version.new(head_version)).to be > Gem::Version.new(main_version)
  end
end
