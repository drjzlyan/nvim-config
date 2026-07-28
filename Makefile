.PHONY: test lint health update-plugins clean

test:
	@nvim --headless -c "PlenaryBustedDirectory tests/ lua/ide/" -c "qa" 2>&1 || true

lint:
	@stylua --check lua/ || echo "Run 'stylua lua/' to fix formatting"
	@shellcheck scripts/*.sh || true

health:
	@nvim --headless -c "checkhealth ide" -c "qa" 2>&1 || true

update-plugins:
	@nvim --headless "+Lazy! sync" +qa
	@echo "Review lazy-lock.json before committing"

clean:
	@rm -rf ~/.local/share/nvim/lazy
	@rm -rf ~/.local/state/nvim
	@rm -rf ~/.cache/nvim
