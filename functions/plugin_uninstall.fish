function plugin_uninstall
    set --local enabled_plugins (path basename $plugins | string replace --regex "@.*" "")

    for plugin_dir in $_plugins_dir/*
        set --local plugin_name (path basename $plugin_dir)
        if not contains -- $plugin_name $enabled_plugins
            read --local --nchars 1 --prompt-str "$plugin_name is disabled, uninstall? (y/N) " answer
            if test (string lower $answer) = y
                for conf in $plugin_dir/conf.d/*.fish
                    emit (path basename $conf | path change-extension '')_uninstall
                end

                # `--force` needed for `.git` directory
                rm --recursive --force $plugin_dir

                echo Uninstalled (set_color --bold)$plugin_name(set_color normal)
            end
        end
    end
end
