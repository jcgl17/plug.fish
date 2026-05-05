function plugin_update
    # iterate by index to allow dynamic allocation
    for i in (seq (count $plugins))
        set --local repo (string split -- @ $plugins[$i])
        set --local plugin_name (path basename $repo[1])
        set --local plugin_dir $_plugins_dir/$plugin_name

        if contains $plugin_name $plugins_pinned
            echo Skipping (set_color --bold)$plugin_name(set_color normal)
        else
            echo Updating (set_color --bold)$plugin_name(set_color normal)

            if set --query repo[2]
                # get latest tag and update plugin name
                set --function latest_tag (git -C $plugin_dir tag --sort -creatordate | head --lines 1)
                set plugins[$i] $repo[1]@$latest_tag

                echo Updating to version (set_color --bold)$latest_tag(set_color normal)
            else
                # no revision, simply pull from HEAD
                set --function latest_tag HEAD
            end

            # --filter blob:none -> only download files when needed
            # --depth 1 -> no history
            # uses SSH
            git -C $plugin_dir fetch \
                --quiet --filter blob:none \
                --depth 1 \
                origin $latest_tag
            git -C $plugin_dir checkout --quiet FETCH_HEAD

            for conf in $plugin_dir/conf.d/*.fish
                # Support masking
                contains (path basename $conf) $user_conf || source $conf
                emit (path basename $conf | path change-extension '')_update
            end
        end
    end
end
