# AutoScroll 2.0

https://github.com/Extensions-Vault/AutoScroll

## CHANGELOG:

[**Findings addressed:**](https://github.com/callumlocke/json-formatter/compare/master...Extensions-Vault:json-formatter:vault/v0.7.2)

- (`MEDIUM`): Extension fingerprinting via web-accessible SVGs -- eliminated by inlining as data URIs
- (`MEDIUM`): Persistent <auto-scroll> element in every page -- now injected only during active scrolling and removed after
- (`LOW`): Division by zero in scale() -- guarded with fallback to 1
- (`INFO`): Dead shadow DOM fallback code -- removed
- (`LOW`): Debug console.log -- removed
- (`LOW`): Error disclosure alerts -- replaced with generic messages
- (`LOW`): Unguarded JSON.parse -- wrapped in try-catch
- (`INFO`): .DS_Store files -- added .gitignore