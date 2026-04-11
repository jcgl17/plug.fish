set --query _plugins_dir && exit

set --global _plugins_dir $__fish_user_data_dir/plugins
set --local user_conf (path basename $__fish_config_dir/conf.d/*.fish)

for plugin in $plugins
    # plugins are URLs of the form host.com:user/repo[@revision]
    # default revision is HEAD
    set --local repo (string split -- @ $plugin)
    or set --local repo[2] HEAD
    set --local plugin_name (path basename $repo[1])
    set --local plugin_dir $_plugins_dir/$plugin_name

    set fish_complete_path \
        $fish_complete_path[1] \
        $plugin_dir/completions \
        $fish_complete_path[2..]
    # Functions should be available before emitting events
    set fish_function_path \
        $fish_function_path[1] \
        $plugin_dir/functions \
        $fish_function_path[2..]

    test -e $plugin_dir || set --local install

    if set --query install
        echo Installing (set_color --bold)$plugin_name(set_color normal)

        # --filter blob:none -> only download files when needed
        # --revision $repo[2] --depth 1 -> only consider state at revision (no history)
        git clone \
            --quiet --filter blob:none \
            --revision $repo[2] --depth 1 \
            git@$repo[1] $plugin_dir
    end

    for conf in $plugin_dir/conf.d/*.fish
        # Support masking
        contains (path basename $conf) $user_conf && continue

        source $conf
        set --query install && emit (path basename $conf | path change-extension '')_install
    end
end
