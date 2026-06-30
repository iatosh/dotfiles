# Japanese Business Email Skill

A Claude Code skill for writing professional Japanese business emails with correct keigo (honorifics), seasonal greetings (時候の挨拶), and proper structure.

## What It Does

- **Keigo Guidance**: Correct usage of teineigo, sonkeigo, and kenjogo
- **Email Structure**: 7-part Japanese business email format
- **Seasonal Greetings**: Month-by-month 時候の挨拶 reference
- **Templates**: Meeting requests, thank you notes, apologies
- **Common Mistakes**: Avoid double honorifics and other errors

## Installation

### Using npx add-skill
```bash
npx add-skill ronantakizawa/japanese-email
```

### Using npx skills
```bash
npx skills add ronantakizawa/japanese-email
```

### Manual Installation
```bash
git clone https://github.com/ronantakizawa/japanese-email ~/.claude/skills/japanese-email
```

## Usage

Once installed, the skill activates when you ask Claude Code to:
- Write a Japanese business email
- Convert casual Japanese to keigo
- Check keigo usage in an email
- Add seasonal greetings to correspondence

### Example Prompts

```
Write a Japanese business email requesting a meeting with Tanaka-san

Convert this email to proper keigo: 明日資料を送る

What's the correct seasonal greeting for October in Japanese?

Check this Japanese email for keigo errors
```

## Structure

```
japanese-email/
├── SKILL.md                          # Main skill file
├── reference/
│   ├── keigo-examples.md             # Verb transformation tables
│   └── seasonal-greetings.md         # 時候の挨拶 by month
├── README.md
├── LICENSE
└── marketplace.json
```

## References

- [Japanese Business Email Guide (Coto Academy)](https://cotoacademy.com/ultimate-guide-japanese-emails/)
- [Seasonal Greetings (freee)](https://www.freee.co.jp/kb/kb-invoice/seasonal-greetings/)
- [Business Keigo (TCJ)](https://tcj-education.com/blog/useful-keigo-words-to-use-at-work-business-japanese/)
- [Japanese Honorifics Dataset](https://huggingface.co/datasets/ronantakizawa/japanese-honorifics)

## License

MIT
