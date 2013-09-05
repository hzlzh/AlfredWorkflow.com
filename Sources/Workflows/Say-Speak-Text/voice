#!/usr/bin/env bash

###
# Author: Michael Klement <mklement0+gh@gmail.com>
# License: MIT
# Version: 0.2
#
# Invoke with -h for help.
###

THIS_NAME=$(basename "$BASH_SOURCE")

# Helper function for exiting with error message due to runtime error.
#   die [errMsg [exitCode]]
# Default error message states context and indicates that execution is aborted. Default exit code is 1.
# Prefix for context is always prepended.
# Note: An error message is *always* printed; if you just want to exit with a specific code silently, use `exit n` directly.
die() {
    echo "$THIS_NAME: ERROR: ${1:-"ABORTING due to unexpected error."}" 1>&2
    exit ${2:-1} # Note: If the argument is non-numeric, the shell prints a warning and uses exit code 255.
}

# Helper function for exiting with error message due to invalid parameters.
#   dieSyntax [errMsg]
# Default error message is provided, as is prefix and suffix; exit code is always 2.
dieSyntax() {
    echo "$THIS_NAME: PARAMETER ERROR: ${1:-"Invalid parameter(s) specified."} Use -h for help." 1>&2
    exit 2
}

# Command-line help.
if [[ "$1" == '--help' || "$1" == '-h' ]]; then
    cat <<EOF
Synopsis:
    $THIS_NAME [options] [-d | voiceName ...]
    $THIS_NAME --set newDefaultVoiceName

Description:
  Returns information about the voices that can be used with OS X's text-to-speech synthesis
  or sets the default voice. Optionally speaks demo or specifiable text.

  1st synopsis form:
    Lists the name, language identifier and demo text for the default voice or the
    specified voice(s).

    If no voice is specified, all *active* voices are listed, sorted by voice name.
    Use -a if you want all *installed* voices listed (this is the same as running \`say -v \?\`).
    Specifying voices explicitly always allows selecting from all *installed* voices.

    Options:

      -d, --get-default ... outputs the name of the current system *default* voice, 
        along with its language identifier and demo text; e.g.
        'Alex                en_US    # Most people recognize me by my voice.'
        The same format is used if you specify one or more voice names explicitly,
        or specify neither -d nor a voice name.
        -b or -i offer alternative output formats.

      -l, --list-for-lang ... lists the voices that match the specified language identifier
        or prefix; e.g., "en" will match all English variants ("en_US", "en_GB", ...).
        Use of "-" is optional and case is ignored so that, e.g., "enus" matches "en_US".

      -L, --list-langs ... lists the language identifiers for which at least
        one voice is active/installed, sorted alphabetically;
        language identifiers are composed of a general language identifier 
        and a regional identifier; e.g., "en_US" for US English.

      -a, --all-installed ... if no voice is specified, lists *all installed* voices
        as opposed to *active* ones (selected for active use via 
        System Preferences > Dication & Speech - typically a subset of all installed
        ones).

      -k, --speak "text" ... speaks the specified text using the specified or all
        installed voices.

      -K, --speak-demo ... speaks the demo text associated with the voice(s).

      -b, --bare ... limits output to voice names.

      -i, --internals ... prints internal voice identifiers, used behind the scenes
          to make a voice the default voice.

  2nd synopsis form:
    -s, --set-default newDefaultVoiceName ... makes the specified voice the 
      default voice; run just $THIS_NAME to get a list of installed voices.

  Use System Preferences > Dictation & Speech to manage the set of active voices,
  install additional voices, and control other aspects of text-to-speech synthesis.

  The strength of this utility is voice management and speaking with *sets* of
  voices.
  By contrast, to just speak text with the default voice or a specified single voice,
  it is easier to use \`say\` directly; e.g.:
    say do something # equivalent of: $THIS_NAME -d -k "do something" 

Examples:
    $THIS_NAME            # lists all active voices
    $THIS_NAME -a         # lists all *installed* voices
    $THIS_NAME alex       # prints information about voice 'Alex'
    $THIS_NAME -s alex    # makes 'Alex' the new default voice
    $THIS_NAME -L         # lists languages for which at least one voice is active
    $THIS_NAME -K         # speaks the respective demo text with all active voices
    $THIS_NAME -k "test" alex agnes # says "text" with voices Alex and Agnes
    $THIS_NAME -K -l "es" # speaks the demo text with active Spanish voices

EOF
    exit 0
fi

# See also: getVoiceInternals()
getLegacyVoiceInternals() {

  local internalVoiceName=${1// /}

  # --- Begin: list of numeric creator and voice IDs for *legacy* voices.
  # Note: Obtained by systematically making each legacy voice that is preinstalled on a US-English OS X 10.8.3 the default voice
  #       and then examining ~/Library/Preferences/com.apple.speech.voice.prefs.plist
  #       Legacy voices are those that do not have VoiceAttributes/VoiceSynthesizerNumericID and VoiceAttributes:VoiceNumericID keys in their
  #       respective /System/Library/Speech/Voices/${voiceNameNoSpaces}.SpeechVoice/Contents/Info.plist files.
  #       !! There is 1 EXCEPTION: The voice that System Preferences and its preferences file call "Pipe Organ" is just named 
  #       !! "Organ" in the actual voice bundle's path and Info.plist file.
  VoiceCreator_Agnes=1734437985
  VoiceID_Agnes=300
  VoiceCreator_Albert=1836346163
  VoiceID_Albert=41
  VoiceCreator_Alex=1835364215
  VoiceID_Alex=201
  VoiceCreator_BadNews=1836346163
  VoiceID_BadNews=36
  VoiceCreator_Bahh=1836346163
  VoiceID_Bahh=40
  VoiceCreator_Bells=1836346163
  VoiceID_Bells=26
  VoiceCreator_Boing=1836346163
  VoiceID_Boing=16
  VoiceCreator_Bruce=1734437985
  VoiceID_Bruce=100
  VoiceCreator_Bubbles=1836346163
  VoiceID_Bubbles=50
  VoiceCreator_Cellos=1836346163
  VoiceID_Cellos=35
  VoiceCreator_Deranged=1836346163
  VoiceID_Deranged=38
  VoiceCreator_Fred=1836346163
  VoiceID_Fred=1
  VoiceCreator_GoodNews=1836346163
  VoiceID_GoodNews=39
  VoiceCreator_Hysterical=1836346163
  VoiceID_Hysterical=30
  VoiceCreator_Junior=1836346163
  VoiceID_Junior=4
  VoiceCreator_Kathy=1836346163
  VoiceID_Kathy=2
  VoiceCreator_Organ=1836346163 # !! Shows up as "*Pipe *Organ" in System Preferences and preferences file.
  VoiceID_Organ=31
  VoiceCreator_Princess=1836346163
  VoiceID_Princess=3
  VoiceCreator_Ralph=1836346163
  VoiceID_Ralph=5
  VoiceCreator_Trinoids=1836346163
  VoiceID_Trinoids=9
  VoiceCreator_Vicki=1835364215
  VoiceID_Vicki=200
  VoiceCreator_Victoria=1734437985
  VoiceID_Victoria=200
  VoiceCreator_Whisper=1836346163
  VoiceID_Whisper=6
  VoiceCreator_Zarvox=1836346163
  VoiceID_Zarvox=8
  # --- End: list of numeric creator and voiced IDs for *legacy* voices

  vName_VoiceCreator="VoiceCreator_$internalVoiceName"
  vName_VoiceID="VoiceID_$internalVoiceName"

  VoiceCreator=${!vName_VoiceCreator}
  VoiceID=${!vName_VoiceID}

}

# Determines the internal identifiers of a voice as (partially) needed to set a given voice as the default voice.
# Sets the following script-global variables:
#   InternalVoiceName
#   VoiceCreator
#   VoiceID
getVoiceInternals() {

  local voiceName=$1
  local plistFile

  # Locate the voice-specific Info.plist file (as of OS X 10.8.3)
  # Note: Some voice names have embedded spaces, but their corresponding folder names have the spaces removed.
  #       !! We assume a case-insensitive filesystem.
  plistFile="/System/Library/Speech/Voices/${voiceName// /}.SpeechVoice/Contents/Info.plist"

  if [[ ! -f $plistFile ]]; then
    # !! There is 1 EXCEPTION to the voice-name-to-filename mapping: "Pipe Organ" doesn't become "PipeOrgan", but just "Organ".
    egrep -i "^pipeorgan$" <<<"${voiceName// /}" &> /dev/null && plistFile="/System/Library/Speech/Voices/Organ.SpeechVoice/Contents/Info.plist"
    [[ -f $plistFile ]] || die "'$voiceName' is not an installed voice."
  fi

  # Determine the relevant IDs we need to switch the default voice.
  # Note: We're setting *script-global* variables here.
  InternalVoiceName=$(/usr/libexec/PlistBuddy -c "print :CFBundleName" $plistFile) || die "Voice '$voiceName': failed to obtain internal voice name."

  VoiceCreator=$(/usr/libexec/PlistBuddy -c "print :VoiceAttributes:VoiceSynthesizerNumericID" "$plistFile" 2>/dev/null) 
  if [[ $? -ne 0 ]]; then # Must be a *legacy* voice - we take VoiceCreator and VoiceID from a hard-coded list.
    getLegacyVoiceInternals "$InternalVoiceName"
    [[ -n $VoiceCreator && -n $VoiceID ]] || die "Voice '$voiceName': failed to obtain numeric creator and/or voice IDs."
  else
    VoiceID=$(/usr/libexec/PlistBuddy -c "print :VoiceAttributes:VoiceNumericID" "$plistFile" 2>/dev/null) || die "Voice '$voiceName': failed to obtain numeric voice ID."
  fi

}

# Prints a line with voice information:
# - for a specific voice, if specified
# - directly as specified, if a voice-informatinon line is passed in.
# - for all voices, if no parameters are passed
printVoiceInfoLine() {
  local voiceNameOrLine=$1

  # Note: We ultimately simply use the output from say -v \? as is.

  if [[ -z $voiceNameOrLine ]]; then # list for ALL active/installed voices
    listVoices
  elif [[ $voiceNameOrLine == *#* ]]; then # already a voice-information line - print as is
    echo "$voiceNameOrLine"
  else # for specified voice.
    say -v \? | egrep -i "^$voiceNameOrLine +[a-z]{2}[_\-]" || die "'$voiceNameOrLine' is not an installed voice."
  fi

}

# Outputs the internal voice names of those voices that are currently active.
# (I.e., those voices that the user chose to actively work with via System Preferences > Dication & Speech, as a *subset* of all *installed* voices).
listActiveVoicesByInternalName() {

  local FILE_PREFS="$HOME/Library/Preferences/com.apple.speech.voice.prefs.plist"
    # !! As of OS X 10.8.3: The list of voices that are *active by default* (and thus also preinstalled).
  local ACTIVE_BY_DEFAULT=$'com.apple.speech.synthesis.voice.Alex\ncom.apple.speech.synthesis.voice.Bruce\ncom.apple.speech.synthesis.voice.Fred\ncom.apple.speech.synthesis.voice.Kathy\ncom.apple.speech.synthesis.voice.Vicki\ncom.apple.speech.synthesis.voice.Victoria'
  local activeNonDefaults deactivatedDefaults activeDefaults active

  if [[ -f  $FILE_PREFS ]]; then

      # Get all *explicitly activated* voices, *except those that are active *by default*.
      # These are voices that were explicitly selected by the user (and downloaded in the process.)
      # Note that we do NOT include voices from the set of those that are active by default (which also may show up with flag value 1 once their status has been toggled by user action),
      # as we deal with them later.
    activeNonDefaults=$(/usr/libexec/PlistBuddy -c "print" ~/Library/Preferences/com.apple.speech.voice.prefs.plist | egrep ' = 1$' | awk '{ print $1 }' | fgrep -xv "$ACTIVE_BY_DEFAULT")

      # Get the list of *explicitly deactivated* voices among the *active-by-default* ones.
    deactivatedDefaults=$(/usr/libexec/PlistBuddy -c "print" ~/Library/Preferences/com.apple.speech.voice.prefs.plist | egrep ' = 0$' | awk '{ print $1 }' | fgrep -x "$ACTIVE_BY_DEFAULT")

    if [[ -n $deactivatedDefaults ]]; then
        # Remove them from the list of active-by-default ones.
        # In effect: get the list of those active-by-default voices that are *currently* active.
      activeDefaults=$(echo "$ACTIVE_BY_DEFAULT" | fgrep -xv "$deactivatedDefaults")
    else
      activeDefaults=$ACTIVE_BY_DEFAULT
    fi

      # Now merge the activate non-defaults and the non-deactivated active-by-default ones
      # to yield the effective list of active voices:
    active=$activeDefaults
    [[ -n $active ]] && active+=$'\n'
    active+=$activeNonDefaults

  else
      # No prefs. file (pristine installation of OSX): simply return the defaults.
    active=$ACTIVE_BY_DEFAULT
  fi

    # Output the *names* only by extracting them from the bundle IDs; note that premium voices have ".premium" as a suffix.
    # Omit the awk command to output *bundle IDs*.
  echo "$active" | awk -F '\.' '{ sub("\.premium$", ""); print $NF; }'

}

listVoices() {
  if (( allInstalled )); then
    listInstalledVoices || die "Failed to list installed voices."
  else
    listActiveVoices || die "Failed to list active voices."
  fi
}

# List all *active* voices (typically a *subset* of all installed voices, selected by the user for active use via System Preferenes > Dictation & Speech).
listActiveVoices() {

    # Get the internal voice names of all active voices.
    # !! The mapping of internal voice names to friendly ones is predictable - internal names have no embedded spaces - with 1 exception: internal name 'Organ' corresponds to friendly name 'Pipe Organ'.
  local vnamesInternal=$(listActiveVoicesByInternalName | sed 's/^Organ$/PipeOrgan/')

  # Loop over all *installed* voices via `say -v \?` and output each line that matches an *active* voice.
  while read -r line; do # Note that we need this outer loop, so we can pass input lines through unmodified.
  
    # Determine this line's friendly voice name, but without embedded spaces.
    # This makes it identical (except for upper/lowercase) to the internal name in all but one cases
    voiceNameNoSpaces=$(awk '{ sub(" [a-z][a-z][_\-][[:alpha:]]+ +#.+", ""); gsub(" ", ""); print; }' <<<"$line")

    # Output the line, if it matches one of the active voices.
    fgrep -qxi "$vnamesInternal" <<<"$voiceNameNoSpaces" && echo "$line"

  done < <(say -v \?)

  return 0
}

# List all *installed* voices (whether active or not).
listInstalledVoices() {
  say -v \? || die "Failed to list installed voices."
}

# Prints the internal identifiers for the specified voice; if no voice name is given, the following variables must already contain the
# correct values: InternalVoiceName VoiceCreator VoiceID
printVoiceInternals() {
  getVoiceInternals "$1"
  local v result=''
  for v in InternalVoiceName VoiceCreator VoiceID; do
    [[ -z $result ]] && result="$v=${!v}" || result+=" $v=${!v}"
  done
  echo "$result"
}

# Given an internal voice name (as stored in com.apple.speech.voice.prefs when that voice is the default), prints
# the representation that is used by `say` and in the System Preferences > Dictation & Speech GUI.
printFriendlyVoiceName() {
  local internalVoiceName=$1
  local line lineTokens voiceName
  # !! Sadly, the com.apple.speech.voice.prefs preferences file stores the default voice name 
  # !! (a) WITHOUT embedded spaces, and (b) - the only non-algorithmic exception - 
  # !! voice 'Pipe Organ' is internally represented as 'Organ'.
  # !! (Note that the /System/Library/Speech/Voices/${internalVoiceName}.SpeechVoice/Contents/Info.plist files
  # !! also contain only the *internal* name.)
  if [[ $internalVoiceName == 'Organ' ]]; then
    echo 'Pipe Organ'
  else # derive the friendly name from the output of say -v ?
    while read -r line; do # Note: We need a *separate, outer* loop in which we can store each *original* line.
      echo "$line" | sed -E 's/([^ ]) ([^ ])/\1\2/g' | egrep -i "^$internalVoiceName +[a-z]{2}[_\-]" &> /dev/null
      if [[ $? -eq 0 ]]; then # line matches
        # Extract the friendly name: all tokens up to but excluding the language identifier.
        while read -ra lineTokens; do
          # We want to print all but the last token.
          numTokens=${#lineTokens[@]}
          numTokens=$(( numTokens - 1 ))
          voiceName="${lineTokens[@]:0:$numTokens}"
        done < <(echo "$line" | awk -F '#' '{ print $1; }')
        echo "$voiceName"
        return 0
      fi
    done < <(say -v \?)
    return 1 # couldn't find voice
  fi
}

speakText() {
  local voiceName=$1
  local text=$2

  if [[ -z $text ]]; then # No text specified? Use demo text.
    text=$(say -v \? | egrep -i "^$voiceName +[a-z]{2}[_\-]" | awk -F '#' '{ print $2; }')
  fi

  say -v "$voiceName" -- "$text"
}

# Preprocess parameters: expand compressed options to individual options; e.g., '-ab' to '-a -b'
params=() decompressed=0 argsReached=0 p=''
for p in "$@"; do
    if [[ $argsReached -eq 0 && $p == -[a-z,A-Z,0-9]?* ]]; then # compressed options?
        decompressed=1
        params+=(${p:0:2})
        for (( i = 2; i < ${#p}; i++ )); do
            params+=("-${p:$i:1}")
        done
    else
        [[ $p == '--' ]] && argsReached=1
        params+=("$p")
    fi
done
if (( decompressed )); then set -- "${params[@]}"; fi; unset params decompressed argsReached p # Replace "$@" with the expanded parameter set.

# Option-parameters loop.
setDefault=0
listLangs=0
langIdSpec=''
listForLang=0
allInstalled=0
bare=0
getDefault=0
getInternals=0
speak=0
text=''
while (( $# )); do
  case "$1" in
    -s|--set-default)
      setDefault=1
      ;;
    -a|--all-installed)
      allInstalled=1
      ;;
    -d|--get-default)
      getDefault=1
      ;;
    -i|--internals)
      getInternals=1
      ;;
    -b|--bare)
      bare=1
      ;;
    -l|--list-for-lang)
      listForLang=1
      shift
      langIdSpec=$1
      [[ -n $langIdSpec ]] || dieSyntax "Missing option argument."
      ;;
    -L|--list-langs)
      listLangs=1
      ;;
    -k|--speak)
      speak=1
      shift
      text=$1
      [[ -n $text ]] || dieSyntax "Missing option argument."
      ;;
    -K|--speak-demo)
      speak=1
      ;;
    --) # Explicit end-of-options marker.
      shift   # Move to next param and proceed with data-parameter analysis below.
      break
      ;;
    -*) # An unrecognized switch.
      dieSyntax "Unrecognized option: '$1'. To force interpretation as non-option, precede with '--'."
      ;;
    *)  # 1st data parameter reached; proceed with *argument* analysis below.
      break
      ;;
  esac
  shift
done

# The list of target voices, if any, is now contained in $@
# !! We can't easily copy $@ with voiceNames=($@), as params with embedded spaces
# !! would not be handled properly; instead, we continue to use $@ directly,
# !! which allows correct enumeration with for v in "$@"; do

haveVoiceNames=$(( $# > 0 ))

  # No request to set the default language? Print requested information and exit.
if (( ! setDefault )); then

  # Check for incompatible options
  errMsg="Incompatible parameters specified."
  (( haveVoiceNames && ( getDefault || listForLang || listLangs ) )) && dieSyntax "$errMsg" # Note: we allow (and ignore) -a, as a user may think that it is needed to target an inactive voice.
  (( listLangs && (getDefault || getInternals || bare || speak ) )) && dieSyntax "$errMsg"
  (( listForLang && getDefault )) && dieSyntax "$errMsg"
  (( getInternals && bare )) && dieSyntax "$errMsg"

  if (( listLangs )); then # List the distinct set of languages.
    listVoices | egrep -o ' [a-z]{2}[_\-]\w+ +#' | awk '{ print $1 }' | sort | uniq
  else  # List information for either all (installed or active) voices, the default voice, or explicitly specified voices.

    if (( getDefault )); then         # DEFAULT-voice information
        # Note: SelectedVoiceName actually contains the 'friendly' name of the default voice.
      voiceName=$(defaults read com.apple.speech.voice.prefs SelectedVoiceName) || die
      if (( getInternals )); then
        printVoiceInternals "$voiceName"  # printVoiceInternals does its own error handling
      else          
        if (( bare )); then
          echo "$voiceName"
        else
          printVoiceInfoLine "$voiceName" # printVoiceInfoLine does its own error handling
        fi
      fi
      if (( speak )); then speakText "$voiceName" "$text"; fi

    elif (( haveVoiceNames )); then    # SPECIFIC voice(s) specified.

      for voiceName in "$@"; do
        if (( getInternals )); then
          printVoiceInternals "$voiceName" # printVoiceInternals does its own error handling
        elif (( bare )); then # output voice name only !! doesn't make much sense, as the voice name was provided - only conceivable value: learning the original capitalization of the name
          # Note: voice names can have embedded spaces, so we can't just grab the 1st token and assume it's
          #       the full voice name. All we know is that the last token before the '#' is language ID, so
          #       all preceding tokens make up the voice name.
          while IFS=' ' read -ra lineTokens; do
            # We want to print all but the last token.
            numTokensInName=$(( ${#lineTokens[@]} - 1 ))
            echo "${lineTokens[@]:0:$numTokensInName}"
          done < <(printVoiceInfoLine "$voiceName" | awk -F '#' '{ print $1; }')
        else # default output via `say`.
          printVoiceInfoLine "$voiceName" # printVoiceInfoLine does its own error handling
        fi
        if (( speak )); then speakText "$voiceName" "$text"; fi
      done

    elif (( listForLang )); then    # voices for a GIVEN LANGUAGE

      shopt -s nocasematch # we're performing case-INsensitive matching of the language ID below.

      while read -r line; do # read output from `say -v \?` (indirectly, via listVoices()) line by line: note that we need this outer loop, so we can pass lines through unmodified.
        # Determine this line's voice name and language
        while IFS=' ' read -ra lineTokens; do
          # Note: voice names can have embedded spaces, so we can't just grab the 1st token and assume it's
          #       the full voice name. All we know is that the last token before the '#' is language ID, so
          #       all preceding tokens make up the voice name.
          # We want to get all but the last token from 
          numTokens=${#lineTokens[@]}
          numTokensInName=$(( numTokens - 1 ))
          voiceName="${lineTokens[@]:0:$numTokensInName}"
          langId="${lineTokens[@]:$(( numTokens - 1 )):1}"
        done < <(echo "$line"| awk -F '#' '{ print $1; }') || die
        # See if the line at hand matches the specified language, ignoring punctuation and differences in case.
        if [[ ${langId//[_\-]/} == ${langIdSpec//[-\_]/}* ]]; then
          if (( getInternals )); then
            printVoiceInternals "$voiceName" # printVoiceInternals does its own error handling
          elif (( bare )); then
            echo "$voiceName"
          else
            printVoiceInfoLine "$line"
          fi
          if (( speak )); then speakText "$voiceName" "$text"; fi
        fi
      done < <(listVoices) || die

    else                            # ALL active/installed voices

      while read -r line; do # read output from `say -v \?` (indirectly, via listVoices()) line by line: note that we need this outer loop, so we can pass lines through unmodified.
        # Determine this line's voice name.
        while IFS=' ' read -ra lineTokens; do
          # Note: voice names can have embedded spaces, so we can't just grab the 1st token and assume it's
          #       the full voice name. All we know is that the last token before the '#' is language ID, so
          #       all preceding tokens make up the voice name.
          # We want to get all but the last token from 
          numTokensInName=$(( ${#lineTokens[@]} - 1 ))
          voiceName="${lineTokens[@]:0:$numTokensInName}"
        done < <(echo "$line"| awk -F '#' '{ print $1; }') || die
        if (( getInternals )); then
          printVoiceInternals "$voiceName" # printVoiceInternals does its own error handling
        elif (( bare )); then
          echo "$voiceName"
        else
          printVoiceInfoLine "$line"
        fi
        if (( speak )); then speakText "$voiceName" "$text"; fi
      done < <(listVoices) || die

    fi

  fi

  # We're done.
  exit 0

fi

  # Getting here means: set a new default voice.

  # Check for complete and incompatible parameters.
(( haveVoiceNames )) || dieSyntax "Missing parameter."
(( $# == 1 )) || dieSyntax "Too many parameters specified."
(( getDefault || allInstalled || bare || listLangs || listForLang )) && dieSyntax "Incompatible parameters specified."

  # Get the internal identifiers needed to switch the default voice.  
getVoiceInternals "$1"

  # Using the internal voice name, get the 'friendly' representation as used by `say`, properly capitalized.
voiceName=$(printFriendlyVoiceName "$InternalVoiceName")

  # Write the identifiers for the new default voice.
defaults write com.apple.speech.voice.prefs 'SelectedVoiceCreator' -int $VoiceCreator || die
defaults write com.apple.speech.voice.prefs 'SelectedVoiceID' -int $VoiceID || die
defaults write com.apple.speech.voice.prefs 'SelectedVoiceName' -string "$voiceName" || die # Note: SelectedVoiceName actually contains the *friendly*, not the internal name.


  # Report success.
echo "Default voice changed to '$voiceName'."

if (( speak )); then speakText "$voiceName" "$text"; fi   # do NOT use $SelectedVoiceName; speakText() uses `say` and thus requires the latter's representation.
