function link
    set source_ "$PWD/$argv[1]"
    if ! test -e $source_
        echo "Source file doesn't exist: $argv[1]"
        return
    end

    set destination $HOME/$argv[2]

    set linked_to (readlink $destination)
    if test -n "$linked_to"
        if test "$source_" != "$linked_to"
            echo "Already linked to different target: $linked_to -> ~/$argv[2] (tried $argv[1])"
        end
        return
    end

    echo "Linked $argv[1] -> ~/$argv[2]"
    ln -sf $source_ $destination
end

function link_to_dot
    link $argv[1] .$argv[1]
end

link config/hushlogin .hushlogin
link config/vscode/keybindings.json "Library/Application Support/Code/User/keybindings.json"
link config/vscode/settings.json "Library/Application Support/Code/User/settings.json"
link_to_dot config/fish/config.fish
link_to_dot config/git
link_to_dot config/mise
link_to_dot config/starship.toml
link_to_dot config/wezterm
