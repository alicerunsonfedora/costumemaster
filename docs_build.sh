
echo "Starting Jazzy build..."
jazzy \
--clean \
--theme jony \
--author "Marquis Kurt" \
--author_url https://marquiskurt.net \
--github_url https://github.com/alicerunsonfedora/CS400 \
--min-acl internal \
--title "The Costumemaster" \
--exclude="./Conscious/Classes/App/*,./Conscious/Views/*,./Conscious/Assets/TealConverse.mlmodel/*" \
--documentation=Guides/*.md \
--config .jazzy.yml \
--build-tool-arguments -workspace,Conscious.xcodeproj/project.xcworkspace,-scheme,"Game"
if [ -d "build" ]; then
  rm -rf build
fi
echo costumemaster.marquiskurt.net >> docs/CNAME
echo "Done."
