# content-module-audit

Agent skill for auditing a content module (a Rails model that includes
`Katalyst::Content::Container`) against Katalyst Content best practices.
See [SKILL.md](./SKILL.md).

To use it from your own projects, symlink it into your agent's skills
directory. The `content-audit` skill references its siblings by relative
path, so link the three content audit skills together:

```shell
# from the root of your katalyst/content clone
for skill in content-audit content-module-audit content-item-audit; do
  ln -s "$PWD/.agents/skills/$skill" ~/.claude/skills/$skill
done
```
