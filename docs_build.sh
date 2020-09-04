echo "Starting Jazzy build..."
bundle exec jazzy \
--clean \
--theme jony \
--author "Marquis Kurt" \
--author_url https://marquiskurt.net \
--github_url https://github.com/alicerunsonfedora/CS400 \
--min-acl internal \
--title "The Costumemaster" \
--exclude=/*/Classes/App/* \
--build-tool-arguments -workspace,Conscious.xcodeproj/project.xcworkspace,-scheme,"Conscious"
rm -r build
echo "Done."
