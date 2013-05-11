function! s:commit_hash(commit)
  let commit = (a:commit == '') ? 'HEAD' : a:commit
  redir => fugitive_output
  silent exe 'Git rev-parse "' . commit . '"'
  redir END
  let commit_hash = substitute(fugitive_output, '.*' . commit . '.*\([a-z0-9]\{40\}\).*', '\1', '')
  return commit_hash
endfunction

function! s:repository_and_owner()
  redir => fugitive_output
  silent exe 'Git remote -v'
  redir END
  let owner_repository = substitute(fugitive_output, '.*origin.*[/:]\(.\+/.\+\)\.git.*', '\1', '')
  return owner_repository
endfunction

function! s:last_n_commit_hashes(n)
  redir => fugitive_output
  silent exe 'Git log --pretty=\%h -n' . a:n
  redir END
  let last_commits = substitute(fugitive_output, '.*-n' . a:n , '', '')
  return split(last_commits)
endfunction

function! s:travis_builds(owner_and_repo)
  let url = 'http://api.travis-ci.org/repos/'. a:owner_and_repo . '/builds'
  let response = webapi#http#get(url, '', {})
  return webapi#json#decode(response.content)
endfunction

function! s:travis_build_url(owner_and_repo, commit_hash)
  let builds = s:travis_builds(a:owner_and_repo)
  for build in builds
    if build['commit'] == a:commit_hash
      return 'https://travis-ci.org/' . a:owner_and_repo . '/builds/'. build['id']
    endif
  endfor
endfunction

"Thanks for @mattn for s:get_browser_command and s:open_browser found in https://github.com/mattn/gist-vim

function! s:get_browser_command()
  let browser_command = get(g:, 'browser_command', '')
  if browser_command == ''
    if has('win32') || has('win64')
      let browser_command = '!start rundll32 url.dll,FileProtocolHandler %URL%'
    elseif has('mac') || has('macunix') || has('gui_macvim') || system('uname') =~? '^darwin'
      let browser_command = 'open %URL%'
    elseif executable('xdg-open')
      let browser_command = 'xdg-open %URL%'
    elseif executable('firefox')
      let browser_command = 'firefox %URL% &'
    else
      let browser_command = ''
    endif
  endif
  return browser_command
endfunction

function! s:open_browser(url)
  let cmd = s:get_browser_command()
  if len(cmd) == 0
    redraw
    echohl WarningMsg
    echo "It seems that you don't have general web browser. Open URL below."
    echohl None
    echo a:url
    return
  endif
  if cmd =~ '^!'
    let cmd = substitute(cmd, '%URL%', '\=shellescape(a:url)', 'g')
    silent! exec cmd
  elseif cmd =~ '^:[A-Z]'
    let cmd = substitute(cmd, '%URL%', '\=a:url', 'g')
    exec cmd
  else
    let cmd = substitute(cmd, '%URL%', '\=shellescape(a:url)', 'g')
    call system(cmd)
  endif
endfunction

function! s:CommitRefComplete(A,L,P) abort
  let args = ['HEAD^', 'HEAD~'] + s:last_n_commit_hashes(10)
  if a:A == ''
    return args
  else
    return filter(args,'v:val[0 : strlen(a:A)-1] ==# a:A')
  endif
endfunction

autocmd User Fugitive command! -nargs=? -buffer -complete=customlist,s:CommitRefComplete GTravisBrowse :execute s:open_browser(s:travis_build_url(s:repository_and_owner(), s:commit_hash(<q-args>)))
