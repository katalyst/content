# content-audit

Agent skill for auditing a Rails application's entire Katalyst Content
integration: gem setup, then every container model and custom item type via
the focused `content-module-audit` and `content-item-audit` skills.
See [SKILL.md](./SKILL.md).

To use it from your own projects, symlink it into your agent's skills
directory. This skill references its siblings by relative path, so link the
three content audit skills together:

```shell
# from the root of your katalyst/content clone
for skill in content-audit content-module-audit content-item-audit; do
  ln -s "$PWD/.agents/skills/$skill" ~/.claude/skills/$skill
done
```
