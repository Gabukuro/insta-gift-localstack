
REPOS = \
    https://github.com/Gabukuro/insta-gift-api.git,go \
    https://github.com/Gabukuro/insta-gift-app,vuejs \
    https://github.com/Gabukuro/gift-prediction-service.git,python

.PHONY: clone run-localstack terraform-init terraform-apply

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

run-localstack:
	@docker-compose up -d

terraform-init:
	@terraform init

terraform-apply:
	@terraform apply -auto-approve

deploy: run-localstack terraform-init terraform-apply
