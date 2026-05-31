#!/usr/bin/env zsh

function w_ () {

  command w; line  #r)DEBUG

  # —— Setup & Constants ———————————————————————————————————————————————————— #

  setopt local_options warn_create_global

  local -ri 10 row_min_width=4

  local -ra titles=( 'USER' 'TTY' 'FROM' 'LOGIN@' 'IDLE' 'WHAT' )
  local -ra sections=( "${(@L)titles//@}" )

  local -r row_sep=─ column_sep=│ title_sep=┼
  local -r row_delim="${(l: row_min_width - 1 ::0:)RANDOM} "

  # —— Read Input & Create Dynamic Vars ————————————————————————————————————— #

  # `-h` means exclude headers
  local -ra input_lines=( "${(@f)$( command w -h )}" )

  local -a    "${(@)^sections}_arr"
  local -i 10 "${(@)^sections}_len"=-1

  # —— Populate Arrays & Find Max Lens —————————————————————————————————————— #

  local -i 10 section_len
  local line content section

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

  # —— Pad Array Elems & Add Separator —————————————————————————————————————— #

  for section in "${(@)sections}"; {
    eval "${section}_arr=(
      \"\${(@r: ${section}_len + 1 :)^${section}_arr}$column_sep\"
    )"
  }

  typeset -p "${(@)^sections}_arr" #r)DEBUG
  line

  # —— Do Final Formatting & Print —————————————————————————————————————————— #

  setopt extended_glob

  local -i 10 line_no sect_no

  for line_no in {1.."$(( $#input_lines + 2 ))"}; {
    for sect_no in {1.."${#sections}"}; {

      section=" ${(P)${sections[sect_no]/%/_arr[line_no]}}"

      if [[ "$section" == " $row_delim"(' '#)$column_sep ]] {
        section="${section/$column_sep/$title_sep}"
        section="${section//[^$title_sep]/$row_sep}"
      }

      if (( sect_no == $#sections )) section="${section%?}"

      echo -nE "$section"
    }

    echo
  }
}
