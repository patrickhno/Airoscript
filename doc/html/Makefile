all: install
install:
	@echo "\t Installing html documentation"
	@$(INSTALLDATA) *.html $(docdir)/html
	@$(INSTALLDATA) images/* $(docdir)/html/images/

uninstall:
	@echo "Removing html documentation from $(docdir)/html"
	@rm -r $(docdir)/html

