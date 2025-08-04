.RECIPEPREFIX = >

checkpoint:
> @git add -A
> @git commit -m "Checkpoint at $$(date '+%Y-%m-%dT%H:%M:%S%z')"
> @echo Checkpoint realizado
