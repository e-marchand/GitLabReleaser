# GitLab Releaser

A 4D desktop application to manage **packages**, **releases**, and **release links** on GitLab through its REST API v4.

## Features

- **Package Registry** — list, upload, download, and delete generic packages
- **Releases** — create, view, edit, and delete project releases
- **Release Links** — attach, update, and remove asset links on releases
- **Upload & Link** — upload a package and create a release link in one step
- **Token Introspection** — verify scopes, expiry, and access level of your Personal Access Token
- **Persistent Settings** — instance URL, project path, and token are saved locally

## Requirements

- 4D v21 R2 or later

## Getting Started

1. Open `Project/GitLabReleaser.4DProject` in 4D.
2. Run the `main` method.
3. In the **Settings** tab, enter:
   - **GitLab instance URL** (defaults to `https://gitlab.com`)
   - **Project path** (e.g. `my-group/my-project`)
   - **Personal Access Token** with `api` scope
4. Click **Test Connection** to verify, then **Save Settings**.
5. Switch to the **Packages** or **Releases** tab to start managing your project.

## Project Structure

```
Project/
  Sources/
    Classes/
      GitLabAPI.4dm        # GitLab REST API wrapper
      TestStats.4dm         # Test statistics helper
    Forms/
      GitLabReleaser/       # Main UI (Packages / Releases / Settings tabs)
    Methods/
      main.4dm              # Entry point
      test_GitLabAPI.4dm    # Unit tests
```

## License

[MIT](LICENSE) — © e-marchand
