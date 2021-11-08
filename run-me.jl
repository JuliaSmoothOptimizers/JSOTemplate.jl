using UUIDs

print("Thanks for using JSOTemplate. What's your intended package name?: \n")
pkgname = readline()

green(msg) = "\033[0;32m$msg\033[0m"
yellow(msg) = "\033[0;33m$msg\033[0m"

println("""
This script will help using JSOTemplate by performing the following steps:
- Change $(green("JSOTemplate")) to $(green("$pkgname")) wherever it is found
- Change the $(green("UUID")) of the package
- Change file $(green("src/JSOTemplate.jl")) to $(green("src/$pkgname.jl"))
- $(yellow("Remove this script"))
- Create a $(yellow("commit")) with the change
""")


files = split(readchomp(`git ls-tree -r main --name-only`), "\n")
for file ∈ files
  file_type = readchomp(`file $file`)
  match(r"text", file_type) === nothing && continue  # skip binary files
  run(`sed -i "" "s/JSOTemplate/$pkgname/g" "$file"`)
end
println(green("✓ All occurrences of JSOTemplate should have been changed to $pkgname"))

lines = readlines("Project.toml")
uuid = ""
for line in lines
  if line[1:4] == "uuid"
    global uuid = split(line, "\"")[2]
    break
  end
end
new_uuid = string(uuid4())
files = ["Project.toml", "test/Project.toml", "docs/Project.toml"] |> x -> filter(isfile, x)
run(`sed -i "" "s/$uuid/$new_uuid/g" $files`)
println(green("✓ UUID has been updated in $files"))

mv("src/JSOTemplate.jl", "src/$pkgname.jl")
println(green("✓ src/JSOTemplate.jl ⟶ src/$pkgname.jl"))

rm("run-me.jl")
println(green("✓ run-me.jl was removed"))

run(`git add src/$pkgname.jl`)
run(`git commit -am ":robot: [run-me.jl] Change JSOTemplate to $pkgname"`)
println(green("✓ commit was created"))