function plugin_update
    # iterate by index to allow dynamic allocation
    for i in (seq (count $plugins))
        set --local repo (string split -- @ $plugins[$i])
        set --local plugin_name (path basename $repo[1])
        set --local plugin_dir $_plugins_dir/$plugin_name

        if contains $plugin_name $plugins_pinned
            echo Skipping (_bold_echo $plugin_name)
        else
            echo Updating (_bold_echo $plugin_name)

            # shared git fetch arguments
            set --local fetch_args -C $plugin_dir fetch --quiet --filter blob:none --depth 1

            if set --query repo[2]
                # get latest tag and update plugin name
                git $fetch_args --tags
                set --function latest_tag (git -C $plugin_dir describe)
                set plugins[$i] $repo[1]@$latest_tag

                echo Updating to version (_bold_echo $latest_tag)
            else
                # no revision, simply fetch from HEAD
                git $fetch_args origin HEAD
                set --function latest_tag FETCH_HEAD
            end

            git -C $plugin_dir checkout --quiet $latest_tag

            for conf in $plugin_dir/conf.d/*.fish
                # support masking
                contains (path basename $conf) $user_conf || source $conf
                emit (path basename $conf | path change-extension '')_update
            end
        end
    end
end
