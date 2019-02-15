let s:apis = {}

function! ht#api#import(name) abort
  if has_key(s:apis, a:name)
    return deepcopy(s:apis[a:name])
  endif

  let p = {}
  try
    let p = ht#api#{a:name}#get()
    let s:apis[a:name] = deepcopy(p)
  catch /^Vim\%((\a\+)\)\=:E117/
  endtry

  return p
endfunction

function! ht#api#register(name, api) abort
  if !empty(ht#api#import(a:name))
    echoerr '[API]: ' . a:name . ' already existed!'
  else
    let s:apis[a:name] = deepcopy(a:api)
  endif
endfunction

" vim:set fdm=marker sw=2 nowrap: