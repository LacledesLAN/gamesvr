# Dockerfile Specs for active `gamesvr` projects

* Must be located in the root of the repo.
* Must use ".Dockerfile" as the file extension.
* Most projects will only have one Dockerfile, but some projects may have multiple Dockerfiles for different purposes.
  * For a project with one Dockerfile, the default name should be `linux.Dockerfile`, as the default build target is a
  Linux-based image.
* Final image must use a non-root user to run the game server, that user must be created in the Dockerfile, and it
  must be set to use that user via the `USER` instruction in the Dockerfile.
* Multistage builds should be used to reduce the size of the final image, and to ensure that only necessary files are
  included in the final image.
* The final image should be as small as possible, and should not include any unnecessary files or dependencies.
* When possible, the final image should use UTF-8 as the default locale and should include any necessary packages to
  support UTF-8.
* Dockerfiles may specify an alternative escape character (e.g. `# escape=`) for any builds targetting the Microsoft
  Windows operating system. All other Dockerfile should stick to the default.

## Final Image Requirements

The requirements in this section apply only to the final build stage. Earlier stages in multistage builds are exempt.

* Files copied into the final image that are intended to be owned by the runtime user must use
  `COPY --chown=<runtime-user>:<runtime-group>` or equivalent numeric ownership.
* `ADD` must not be used in the final build stage unless automatic extraction of a local archive is specifically
  required and documented in a comment immediately preceding the instruction.

## Build Arguments

* No unused ARGs are allowed.
* Build args should be UPPERCASE with underscores, and should be descriptive of their purpose.
* Build arguments may be placed:
  * Before any `FROM` instructions, for build arguments that are used in the `FROM`
    instruction(s).
  * After the `FROM` instruction, for build arguments that are used in the build process
* Multiple build arguments should use a single ARG instruction, with each value on a separated line using the line
  continuation character (`\`). Each subsequent line should be indented with 4 spaces, and the last line should not have
  a line continuation character.
* For each ARG instruction, arguments should be arranged alphabetically, by key, sorted in ascending order.

## Formatting

* In multi-stage builds, all but the first FROM instruction must:
  * Be proceeded by two blank lines, followed by a comment separator of `#---------------------------------`. There must
    not be a blank line between the comment and the matching FROM instruction.
* There must be at least one blank line between instructions.
  * Comments may appear before an instruction, without a blank line between the comment and the instruction.
* There must always be at least one space character ahead of any trailing line continuation character (`\`).

## Labels

* All labels should be applied via a single `LABEL` instruction in the Dockerfile, with each value on a separated line
  using the line continuation character (`\`). Each subsequent line should be indented with 6 spaces, and the last line
  should not have a line continuation character.
* All label keys should be arranged alphabetically, sorted in ascending order.
* Dockerfiles must include the following labels for the final image:
  * `architecture` - The architecture of the image (by default `amd64`).
  * `com.lacledeslan.build-node` - The name of the host system that built the image.
    * ARG `BUILD_NODE` should be used to pass this value with a default value of `unspecified`.
  * `maintainer` - The maintainer of the image (by default `Laclede's LAN <contact@lacledeslan.com>`).
  * `org.opencontainers.image.created` - The time the image was created in RFC 3339 formatted date-time string
    (e.g., YYYY-MM-DDTHH:MM:SSZ).
    * ARG `BUILD_DATE` should be used to pass this value with a default value of `unspecified`.
  * `org.opencontainers.image.description` - A description of the image (e.g. `<gamename> Dedicated Server`).
  * `org.opencontainers.image.revision` - The revision of the image (e.g. `git rev-parse HEAD`).
    * ARG `GIT_REVISION` should be used to pass the git revision to the Dockerfile (default `unspecified`):
      * it should be set in the build script to the output of `git rev-parse HEAD`.
      * if the git working tree is dirty, append the string `-dirty` to that SHA (for example: `<sha>-dirty`).
  * `org.opencontainers.image.source` - The source of the image (e.g. `https://github.com/LacledesLAN/gamesvr-hl2dm`).
  * `org.opencontainers.image.vendor` - The vendor of the image (e.g. `Laclede's LAN`).
