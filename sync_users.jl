using GitHub
myauth = GitHub.authenticate(ENV["GITHUB_AUTH"])

function update_or_create_user(member, group="")
    member = owner(member, auth=myauth)
    fullname = isnull(member.name) ? get(member.login) : get(member.name)
    location = isnull(member.location) ? "" : get(member.location)
    email = isnull(member.email) ? "" : get(member.email)
    username = lowercase(GitHub.name(member))
    print_with_color(:blue, "Processing user $fullname ($username)\n")
    if !success(`getent passwd $username`)
       print_with_color(:blue, "User does not exist, creating!\n")
       # Create user if it doesn't exist yet
       run(`sudo adduser --disabled-password --gecos "$fullname,$location,,,$email" $username`)
       run(`sudo mkdir -p /home/$username/.ssh`)
    end
    if group != ""
      run(`sudo usermod -a -G $group $username`)
    end
    # Update SSH keys from GitHub
    authorized_keys = join(collect(values(GitHub.pubkeys(member, auth=myauth)[1])),'\n')
    run(pipeline(pipeline(`echo $authorized_keys`,`sudo tee /home/$username/.ssh/authorized_keys`),DevNull))
    run(`sudo chown -R $username:$username /home/$username/.ssh`)
    run(`sudo chmod 600 /home/$username/.ssh/authorized_keys`)
    run(`sudo chmod 700 /home/$username/.ssh`)
    # Create data directory
    run(`sudo mkdir -p /data/$username`)
    run(`sudo chown -R $username:$username /data/$username`)
    run(`sudo chmod 775 /data/$username`)
end

for (orgname, teamname, group) in [("JuliaLang","Contributors","julialang"),
                           ("JuliaComputing","Programmers","juliacomputing")]
    org = owner(orgname, true, auth=myauth)
    team = first(filter(team->get(team.name)==teamname, GitHub.teams(org, auth=myauth)[1]))
    for member in members(team; auth=myauth)[1]
        update_or_create_user(member, group)
    end
end

for user in readlines("EXTRA_USERS")
    update_or_create_user(strip(user))
end
