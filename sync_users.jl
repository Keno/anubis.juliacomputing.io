using GitHub
myauth = GitHub.authenticate(ENV["GITHUB_AUTH"])

for (orgname, teamname, group) in [("JuliaLang","Contributors","julialang"),
                           ("JuliaComputing","Programmers","juliacomputing")]

    org = owner(orgname, true, auth=myauth)
    team = first(filter(team->get(team.name)==teamname, GitHub.teams(org, auth=myauth)[1]))
    for member in members(team; auth=myauth)[1]
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
        run(`sudo usermod -a -G $group $username`)
        # Update SSH keys from GitHub
        authorized_keys = join(collect(values(GitHub.pubkeys(member, auth=myauth)[1])),'\n')
        run(pipeline(pipeline(`echo $authorized_keys`,`sudo tee /home/$username/.ssh/authorized_keys`),DevNull))
        run(`sudo chown -R $username:$username /home/$username/.ssh`)
        run(`sudo chmod 600 /home/$username/.ssh/authorized_keys`)
        run(`sudo chmod 700 /home/$username/.ssh`)
    end
end