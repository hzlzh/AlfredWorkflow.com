# Say - Speak Text

An [Alfred 2](http://alfredapp.com) workflow that **uses OS X's TTS (text-to-speech) feature to speak text aloud**.  
It is especially useful if you handle **many voices**, possibly in **multiple languages** - note that OS X allows on-demand download of voices in other languages.

Aside from speaking text with the default voice, offers the following features:

* Voice selection, optionally with voice-name and target-language filtering.
* Ability to speak text in sequence with multiple voices.
* Rich, dynamic feedback (name of default voice, voice languages, demo text).
* Have selected voices speak their demo text.
* Makes Alfred redisplay with the same query for interactive experimentation.
* Make a new voice the default voice directly from Alfred.
* Option to open System Preferences to manage voices and TTS options.
* Option to use a hotkey to speak the selected text in any application using the default voice (while OS X has such a feature built in, using Alfred is preferable in that it also works with non-native applications).

## Dependencies

* [Alfred 2](http://alfredapp.com) with the [Powerpack add-on](http://www.alfredapp.com/powerpack) - GPB 15 as of spring 2013.
* Developed and tested on `OS X 10.8.3`; *possibly* works on 10.7 and 10.6, too.

## Usage

Note: The workflow uses the set of **active** voices, as defined in `System Preferences`. Active voices are those selected for active use, and are typically a *subset* of the *installed* voices.
Thus, if you want to make an installed voice available to the workflow, make sure it is checked when you go to `System Preferences > Dictation & Speech`, anchor `Text to Speech`, list `System voice:`, and select list item `Customize...`.

*Omitting text always speaks the demo text for each voice.*

The workflow uses a single keyword, **`say`**:

### Speak text with the default voice

Simply specify the text to speak; e.g.

      say I speak, therefore I am.

* To speed things up, no voices are offered by default; type `@` or `#` before or after the text to speak to show the list of active voices (see below).
* Using single and double quotes, even unbalanced, is supported.
* After submitting a command, Alfred redisplays with the same query to facilitate experimentation.

### Speak text with voice selection / filtering

* Type `@` or `#` **before or after** the text to speak to see the list of active voices.
* Type `@{voiceNameOrPrefix}` to filter the list of active voices by name; e.g.:  
  `@alex`  
  Optionally, you can append the name directly to the keyword (no space); e.g.:  
  `sayAlex`  
  Matching is case-sensitive; omit spaces for voice names with embedded spaces.
* Type `#{langIdOrPrefix}` to filter the list of active voices by language ID; e.g.:  
  `#en`  
  If you just type `#`, you'll see the language identifier of each voice in parentheses.  
  Matching is case-sensitive; you can omit the `_` character, e.g., `enus` to match `en_US`.
* You can even use *multiple*, `,`-separated specifiers; e.g.:  
  `@alex,tom`

You only need to type as much of a name or language as is necessary to filter the list down to the desired result.
You can also auto-complete based on the selected result, but this only works for single-token specifiers.

**Whenever more than one voice matches**, the first result item offers to speak the specified (or demo) with **all matching voices**, in sequence.

### Examples:

    say @                                 # Show list of active voices on typing @; submit to speak demo text in all voices.
    say @alex I'm Alex                    # Speak "I'm Alex" with voice Alex.
    sayalex I'm Alex.                     # ditto
    say I'm Alex @alex                    # ditto
    say First Alex, then Jill @alex,jill  # Speak first as Alex, then as Jill.
    say y ahora en español #es            # Speak text with Spanish voice(s).
    say Pottery #enie,enza                # Speak text with Irish and South African voices.

### Make a voice the default voice

Whenever a specific voice is selected in the result list, **simply hold down `Option` while pressing `Return` to make that voice the default voice**.  
A notification will indicate success.

## Configuration

Typing just **`say`**, with no arguments, shows an additional command:

### `Manage Voices`

Opens the `System Preferences` application's `Dictation & Speech` pane where the set of active voices - including on-demand download of additional voices - and other TTS options can be managed.

## Bonus Track: CLI `voice`

The workflow folder contains a command-line utility named `voice`, which can be used stand-alone to provide much of the functionality the workflow offers, notably the ability to change the default voice and to speak text using multiple voices.  
Invoke it with `-h` for help.

## Installation

Download the `Say - Speak Text.alfredworkflow` file and open it (make sure that no dialog is open in Alfred's Preferences).

## Author

Michael Klement (<mklement0+gh@gmail.com>)

## License

MIT

## Changelog

* `0.1` (20 May 2013): initial release 