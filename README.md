# Ginger Prompt
This is a basic prompt for zsh.

# Description
With this prompt, you get some useful information :
- The current working directory: To keep the prompt concise and readable, the displayed path is limited to 3 directories or 20 characters.
  - Inside a Git repository, the prompt displays the current branch, followed by the '●' indicator if you have uncommitted changes.
- In case of error, the exit code will be displayed.
- The execution time of the last command will be displayed on the right side of your terminal.
- The current time is also displayed on the right side of the prompt.

> If you resizing your terminal, the prompt can had a displaying bug, sorry about that :(

<img width="666" height="58" alt="image" src="https://github.com/user-attachments/assets/1f56ee32-51bb-48b0-b280-9c0422cba273" />

# Installation
You can installing manually or execute this command :
```bash
git clone https://github.com/nico-ld/ginger_prompt.git ~/.ginger_prompt && echo "source ~/.ginger_prompt/custom_prompt.zsh" >> ~/.zshrc && source ~/.zshrc
```

> ⚠️ If you already had another special prompt you need to comment it or remove it from your .zhsrc !
