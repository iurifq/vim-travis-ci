let s:configfile = expand('~/.vim-travis-ci')

function! s:commit_hash(commit)
  return matchstr(system('git rev-parse ' . (a:commit == '' ? 'HEAD' : a:commit)), "[a-z0-9]*")
endfunction

function! s:repository_and_owner()
  let git_output = system('git remote -v | grep origin.*push')
  return matchstr(git_output, '.*[:/]\zs.*/.*\ze\.git (push)')
endfunction

function! s:last_n_commit_hashes(n)
  return split(system('git log --pretty=\%h -n' . a:n))
endfunction

function! s:travis_build_url(owner_and_repo, commit_hash)
  return 'https://iurifq.github.io/vim-travis-ci/?repository='. a:owner_and_repo .
        \ '&commit=' . a:commit_hash . '&public=' . s:travis_public_repo() .
        \ '&github_token=' . s:github_token()
endfunction

function! s:travis_public_repo()
  return substitute(s:system('git config --get vim-travis.public'), "\n", '', '')
endfunction

function! s:github_token()
  let auth = ""
  if filereadable(s:configfile)
    let str = join(readfile(s:configfile), "")
    if type(str) == type("")
      let auth = str
    endif
  endif
  return auth
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

function! GTravisBrowse(commit)
  execute s:open_browser(s:travis_build_url(s:repository_and_owner(), s:commit_hash(a:commit)))
endfunction

autocmd User Fugitive command! -nargs=? -buffer -complete=customlist,s:CommitRefComplete GTravisBrowse call GTravisBrowse(<q-args>)
