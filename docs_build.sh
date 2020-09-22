echo "Starting Jazzy build..."
bundle exec jazzy \
--clean \
--config .jazzy.yml \
--build-tool-arguments -workspace,Conscious.xcodeproj/project.xcworkspace,-scheme,"Conscious" \
rm -r build
echo costumemaster.marquiskurt.net >> docs/CNAME
echo "Done."
