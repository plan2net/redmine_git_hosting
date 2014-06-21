module GitHostingHelper

  include Redmine::I18n

  def checked_image2(checked=true)
    if checked
      image_tag 'toggle_check.png'
    else
      image_tag 'exclamation.png'
    end
  end


  def label_with_icon(label, icon, inverse = false, fixed = false)
    css_class = [ "fa", "fa-lg" ]

    css_class.push(icon)

    if inverse
      css_class.push("fa-inverse")
    end

    if fixed
      css_class.push("fa-fw")
      css_class.delete("fa-lg")
    end

    css_class = css_class.join(" ")
    content = content_tag(:i, "", :class => css_class) + label

    return content.html_safe
  end


  def user_allowed_to(permission, project)
    if project.active?
      return User.current.allowed_to?(permission, project)
    else
      return User.current.allowed_to?(permission, nil, :global => true)
    end
  end


  # Post-receive Mode
  def post_receive_mode(prurl)
    label = ""
    if prurl.mode == :github
      label << l(:label_github_post)
      if prurl.split_payloads?
        label <<  "&nbsp;(#{l(:label_split_payloads)})"
      end
    else
      label << l(:label_empty_get)
    end
    return label
  end


  # Mirror Mode
  def mirror_mode(mirror)
    [l(:label_mirror_full_mirror), l(:label_mirror_forced_update), l(:label_mirror_fast_forward)][mirror.push_mode]
  end


  # Refspec for mirrors
  def refspec(mirror, max_refspec = 0)
    if mirror.push_mode == RepositoryMirror::PUSHMODE_MIRROR
      l(:all_references)
    else
      result = []
      result << l(:all_branches) if mirror.include_all_branches
      result << l(:all_tags) if mirror.include_all_tags
      result << mirror.explicit_refspec if (max_refspec == 0) || ((1..max_refspec) === mirror.explicit_refspec.length)
      result << l(:explicit) if (max_refspec > 0) && (mirror.explicit_refspec.length > max_refspec)
      result.join(",<br />")
    end
  end


  def plugin_asset_link(asset_name)
    File.join(Redmine::Utils.relative_url_root, 'plugin_assets', 'redmine_git_hosting', 'images', asset_name)
  end


  def render_feature(repository, feature)
    css_class = 'icon icon-git'

    case feature

      when :repository_deployment_credentials
        label = l(:label_deployment_credentials)
        css_class << ' icon-deployment-credentials'
        enabled = repository.deployment_credentials.active.any?

      when :repository_post_receive_urls
        label = l(:label_post_receive_urls)
        css_class << ' icon-post-receive-urls'
        enabled = repository.post_receive_urls.active.any?

      when :repository_mirrors
        label = l(:label_repository_mirrors)
        css_class << ' icon-mirrors'
        enabled = repository.mirrors.active.any?

      when :git_daemon
        label = l(:label_git_daemon)
        css_class << ' icon-git-daemon'
        enabled = (repository.project.is_public && repository.extra[:git_daemon])

      when :git_http
        label = l(:label_smart_http)
        css_class << ' icon-git-smarthttp'
        enabled = repository.extra[:git_http] != 0

      when :git_notify
        label = l(:label_git_notify)
        css_class << ' icon-git-notify'
        enabled = repository.extra[:git_notify]

    end

    label << (!enabled ? " (#{l(:label_disabled)})" : '')
    css_class << (!enabled ? ' icon-git-disabled' : '')

    content_tag(:span, '', :title => label, :class => css_class)
  end


  def render_hook_state(state)
    case state
      when true
        image = 'true.png'
        tip = ''
      when false
        image = 'exclamation.png'
        tip = ''
      else
        image = 'warning.png'
        tip = state
    end
    return image, tip
  end

end
