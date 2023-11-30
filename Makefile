
REPOS = \
    https://github.com/Gabukuro/insta-gift-api.git,go \
    https://github.com/Gabukuro/insta-gift-app,vuejs \
    https://github.com/Gabukuro/object-detection-service.git,python

.PHONY: clone install-deps

clone:
	@echo "Clonando repositórios..."
	@for repo_lang in $(REPOS); do \
		repo=$$(echo $$repo_lang | cut -d ',' -f 1); \
		lang=$$(echo $$repo_lang | cut -d ',' -f 2); \
		cd ..; \
		echo "Clonando $$repo ..."; \
		git clone $$repo; \
		cd -; \
	done

