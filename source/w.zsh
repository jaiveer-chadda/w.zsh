#!/usr/bin/env zsh

function w_ () {
  command w; line

  setopt local_options warn_create_global warn_nested_var

  local -r row_min_width=4
  local -r column_sep=│

  local -r row_delim="${(l: row_min_width - 1 ::0:)RANDOM} "

  local -ra titles=( 'USER' 'TTY' 'FROM' 'LOGIN@' 'IDLE' 'WHAT' )
  local -ra sections=( "${(@L)titles//@}" )

  local -a    "${(@)^sections}_arr"
  local -i 10 "${(@)^sections}_len"=-1

  # `-h` means exclude headers
  local -ra input_lines=( "${(@f)$( command w -h )}" )

  local line content section
  local -i 10 section_len

  for line in  \
    "$^titles " \
    "${(pr: $#titles * $#row_delim ::$row_delim:)}" \
    "${(@)input_lines}"
  {
    for content section in "${(@)${(s: :)line}:^sections}"; {
      eval "${section}_arr+=( '$content' )"

      # the last section (WHAT), can contain multiple spaces in it
      if [[ "$section" == "$sections[-1]" ]] {
        # so find everything in the line that we haven't included yet
        eval "${section}_arr[-1]+=\"\${line##*\${${section}_arr[-1][-1]}}\""
      }

      # get the length of the section we just created
      local section_len="${(P)#${section/%/_arr[-1]}}"

      if (( section_len > ${section}_len )) local ${section}_len=$section_len
    }
  }

  for section in "${(@)sections}"; {
    eval "${section}_arr=(
      \"\${(@r: ${section}_len + 1 :)^${section}_arr}$column_sep\"
    )"
  }

  typeset -p "${(@)^sections}_arr"
}
