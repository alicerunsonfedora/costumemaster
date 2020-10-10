# The Costumemaster Contribution Guidelines

Thanks for taking a look at The Costumemaster and helping out! Here are a couple of tips and guidelines to follow when
submitting code for review.

## Lint your code with SwiftLint

Please try to follow the conventions laid out in SwiftLint and the custom rules defined in the configuration file. Run the linter before
you submit your code for review.

## Follow commit message conventions

Commit messages on this project follow a type/scope/summary based approach that tries to explains as much as possible while
being concise.


An example is provided below:

```
:bento: [Assets] Update tilemap assets with new destroyed visuals

The tilemap now includes the "destroyed" look that levels can use by switching to "Costumemaster Destroyed". The layout
remains the same to ensure consistency and compatibility when switching between visual sets.
```
- The first component of the message contains an emoji using the Gitmoji standard conventions to capture the type of change being
made. 
- The second component, wrapped in square brackets, contains the scope of the project, which usually pertains to the folders
where files were changed/added/deleted. For multiple folders in different scopes, use a plus sign (ex.: `[Assets + Classes]`). For
multiple folders under the same parent scope, use the parent scope.
- The final component is a summary of the changes being made. Try to be as descriptive and concise as possible. Note that if a lot 
of changes have been made with no clear objective, use "Do stuff" as the summary.
- If you want to provide an addition description, separate it with a line as a new paragraph. 

## Sign your code with GPG.

GPG commit signing helps verify that the code was written and committed by you. Use the `-s` flag when committing to enable
GPG signing. Commits and pull requests without GPG signing will take lower priority.

Example:

```
git commit -s -m ":recycle: [Project] Do stuff"
```

