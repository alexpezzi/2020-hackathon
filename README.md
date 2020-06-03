# 2020-hackathon

## Members
- Alex Pezzi
- Norbert Curiciac

## Idea
### Done:
- Fetch random joke and translate using a popular character (ie. yoda).
  - https://sv443.net/jokeapi/v2
  - https://api.funtranslations.com
### TODO:
- Text-to-speech

## How to
1. Configure character in https://github.com/alexpezzi/2020-hackathon/blob/master/Hackathon/SceneDelegate.swift
2. Build and run to view output.

## Issues:
- Limited time, so configuartion must be done manually in `SceneDelegate.swift`.
- API limit on `https://api.funtranslations.com` (5 per hour).  If you see `The data couldn't be read because it is missing`, then you need wait an hour (or use a vpn).
