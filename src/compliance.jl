# Script to check compliance of the packages wrt the JSOTemplate
using Emporium, Formatting, GitHub

const simple_copy_file_list =
  [".cirrus.yml", ".JuliaFormatter.toml"] ∪ (
    ".github/workflows/" .*
    ["CI.yml", "CompatHelper.yml", "Formatter.yml", "Register.yml", "TagBot.yml"]
  )
const renaming = [
  ".github/workflows/ci.yml" => ".github/workflows/CI.yml",
  ".github/workflows/Ci.yml" => ".github/workflows/CI.yml",
  ".github/workflows/format_pr.yml" => ".github/workflows/Formatter.yml",
  ".github/workflows/register.yml" => ".github/workflows/Register.yml",
]

function template_compliance(repo)
  auth = GitHub.authenticate(ENV["GITHUB_TOKEN"])

  # @info "Cloning repos"
  # clone_organization_repos(
  #   "JuliaSmoothOptimizers",
  #   "cloned_repos",
  #   exclude=["Organization", "JuliaSmoothOptimizers.github.io", "JSOTemplate.jl", ".github"]
  # )

  if length(split(repo, "/")) != 2
    error("repo should have format OWNER/PKGNAME")
  end
  owner, pkg = split(repo, "/")

  clone_folder = mktempdir()
  run(`mkdir -p $clone_folder`)
  @info "Cloning to $clone_folder"
  run(`git clone https://github.com/$owner/$pkg $clone_folder/$pkg`)

  check_and_fix_compliance(
    ".",
    simple_copy_file_list,
    clone_folder,
    auth = auth,
    check_only = false,
    close_older_compliance_prs = true,
    commit_message = "[skip ci] :bot: Template compliance update",
    create_pr = true,
    owner = owner,
    pr_title = "[JSOTemplate.jl] Template compliance update",
    pr_body = "This is an automated PR made from JSOTemplate.jl. If the result is not what you expected, please open an issue or [at] abelsiqueira",
    rename_these_files = renaming,
    template_pkg_name = "JSOTemplate",
  )
end
