function plugin_update
    for i in (seq (count $plugins))
        # remove revision
        set --local repo (string split -- @ $plugins[$i])
        set --local plugin_name (path basename $repo[1])
        set --local plugin_dir $_plugins_dir/$plugin_name

        if contains $plugin_name $plugins_pinned
            echo Skip updating (set_color --bold)$plugin_name(set_color normal)
            continue
        end

        echo Updating (set_color --bold)$plugin_name(set_color normal)

        if set --query $repo[2]
            # get latest tag and update plugin name
            set --function latest_tag (git -C $plugin_dir tag --sort -creatordate | head -n1)
            set plugins[$i] $repo[1]@$latest_tag
        else
            # no revision, simply pull from HEAD
            set --function latest_tag HEAD
        end

        git -C $plugin_dir fetch --quiet --depth 1 origin $latest_tag
        git -C $plugin_dir checkout --quiet FETCH_HEAD

        for conf in $plugin_dir/conf.d/*.fish
            source $conf
            emit (path basename $conf | path change-extension '')_update
        end
    end
end
