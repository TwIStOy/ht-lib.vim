let s:class_base = {
      \ '__name__': '',
      \ '__parents__': [],
      \ '__mro__': [],
      \ '__dict__': {}
      \ }

let s:new_class_types = get(s:, 'new_class_types', {})

function! ht#object#gen() abort
  let classes = globpath(&rtp, 'autoload/ht/object/**/*.vim', 1, 1)
  let pattern = '/autoload/ht/object/'

  let cls_names = []
  for cls in classes
    let name = cls[matchend(cls, pattern):-5]
    let name = substitute(name, '/', '#', 'g')

    call ht#object#{name}#build()
  endfor
endfunction

function! ht#object#new_class(cls) abort
  let rst = deepcopy(s:class_base)
  let rst.__name__ = a:cls
  return rst
endfunction

function! ht#object#register_class(cls) abort
  if !has_key(a:cls, '__name__')
    throw printf('VOO: Class type Required __name__ but missing')
  endif

  let name = a:cls.__name__
  let s:new_class_types[name] = deepcopy(a:cls)
endfunction

function! ht#object#get_class(name) abort
  if !has_key(s:new_class_types, a:name)
    throw printf('VOO: Required class "%s" but not found.', a:name)
  endif

  return s:new_class_types[a:name]
endfunction

function! ht#object#inject(object, ...)
  for cls_name in a:000
    if type(cls_name) == v:t_string
      let cls = ht#object#get_class(cls_name)
    else
      let cls = cls_name
    endif

    for field_name in keys(cls.__dict__)
      if !has_key(a:object, field_name)
        let a:object[field_name] = deepcopy(cls.__dict__[field_name])
      endif
    endfor
  endfor
endfunction

" vim:set fdm=marker sw=2 nowrap:
