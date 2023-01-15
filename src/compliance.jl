# Script to check compliance of the packages wrt the JSOTemplate
using Emporium, Formatting, GitHub

const simple_copy_file_list =
  [".JuliaFormatter.toml"] ∪ (
    ".github/workflows/" .*
    ["CI.yml", "CompatHelper.yml", "Formatter.yml", "Register.yml", "TagBot.yml"]
  )
const renaming = [
  ".github/workflows/ci.yml" => ".github/workflows/CI.yml",
  ".github/workflows/format_pr" => ".github/workflows/Formatter.yml",
  ".github/workflows/register.yml" => ".github/workflows/Register.yml",
]

function template_compliance()
  auth = GitHub.authenticate(ENV["GITHUB_TOKEN"])

  @info "Cloning repos"
  # clone_organization_repos(
  #   "JuliaSmoothOptimizers",
  #   "cloned_repos",
  #   exclude=["Organization", "JuliaSmoothOptimizers.github.io", "JSOTemplate.jl", ".github"]
  # )
  mkdir("cloned_repos")
  cd("cloned_repos") do
    run(`git clone https://github.com/JuliaSmoothOptimizers/DerivativeFreeSolvers.jl`)
  end

  check_and_fix_compliance(
    ".",
    simple_copy_file_list,
    "cloned_repos",
    auth = auth,
    check_only = false,
    close_older_compliance_prs = true,
    create_pr = true,
    owner = "JuliaSmoothOptimizers",
    rename_these_files = renaming,
    template_pkg_name = "JSOTemplate",
  )
end
