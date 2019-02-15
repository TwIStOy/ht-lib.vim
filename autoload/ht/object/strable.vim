let s:has_built = 0
let s:func_verbose = get(s:, 'func_verbose', 0)

function! ht#object#strable#build() abort
  if s:has_built
    return
  endif
  let has_built = 1

  let cls = ht#object#new_class('strable')

  let cls.__dict__['to_string'] = function(s:get_snr('to_string'))

  call ht#object#register_class(cls)
endfunction

function! ht#object#strable#set_func_verbose(verbose) abort
  let s:func_verbose = a:verbose
endfunction

function! s:to_string(...) dict abort
  let handled_list = a:0 > 0 ? a:1 : []
  let attributes = filter(copy(self), 'type(v:val) != v:t_func')

  if s:func_verbose
    let methods = filter(copy(self), 'type(v:val) == v:t_func')
    call extend(attributes, { '__methods__': sort(keys(methods))})
  endif

  return ht#object#strable#_to_string(attributes, handled_list)
endfunction

function! ht#object#strable#_to_string(object, handled_list) abort
  if type(a:object) == v:t_list
    if s:is_already_handled(a:object, a:handled_list)
      return '[...]'
    endif

    call add(a:handled_list, a:object)

    let res = '['
    let res .= join(map(
          \ copy(a:object),
          \ 'ht#object#strable#_to_string(v:val, a:handled_list)'), ', ')
    let res .= ']'
    return res
  elseif type(a:object) == v:t_dict
    if s:is_already_handled(a:object, a:handled_list)
      return '{...}'
    endif

    call add(a:handled_list, a:object)

    if has_key(a:object, 'to_string')
      return a:object.to_string()
    elseif has_key(a:object, '_to_string')
      return a:object._to_string()
    else
      let res = '{'
      let res .= join(
            \ map(items(a:object),
            \ 'string(v:val[0]).": "'
            \ . '.ht#object#strable#_to_string(v:val[1], a:handled_list)'),
            \ ', ')
      let res .= '}'
      return res
    endif
  elseif type(a:object) == v:t_string || type(a:object) == v:t_func
    return string(a:object)
  else
    return a:object
  endif
endfunction

function! s:is_already_handled(object, handled_list) abort
  return ht#api#import('list').contain_entity(a:handled_list, a:object)
endfunction

function! s:get_snr(...)
  if !exists("s:snr")
    let s:snr = matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_snr$')
  endif
  return s:snr . (a:0>0 ? (a:1) : '')
endfunction

