let s:self = {}

function! ht#api#list#get() abort
  return deepcopy(s:self)
endfunction

function! s:self.contain_entity(lst, val) abort
  let found = map(copy(a:lst), 'v:val is a:val')
  return index(found, 1) != -1
endfunction

function! s:self.not_contain_entity(lst, val) abort
  let found = map(copy(a:lst), 'v:val is a:val')
  return index(found, 1) == -1
endfunction

