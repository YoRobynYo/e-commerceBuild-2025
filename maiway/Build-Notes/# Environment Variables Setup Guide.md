# Environment Variables Setup Guide (.env)

## Overview
This guide walks you through setting up your `.env` file for an e-commerce project. Environment variables store sensitive configuration data like API keys and database connections.

## Step 1: Generate a JWT Secret

Create a strong secret for JWT authentication:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

Copy the entire long string that gets generated.

## Step 2: Edit Your .env File

Open your `.env` file for editing:

```bash
nano .env
```

### Nano Editor Tips:
- **Search**: `Ctrl+W` to find text
- **Delete line**: `Ctrl+K`
- **Save**: `Ctrl+O`, then `Enter`
- **Exit**: `Ctrl+X`
- **Paste**: Right-click or `Ctrl+Shift+V`

### Alternative Editors:
```bash
# If nano is difficult, try these instead:
vim .env
gedit .env
code .env
```

## Step 3: Configure Your Environment Variables

Your `.env` file should look like this:

```
DATABASE_URL=sqlite:///./dev.db
JWT_SECRET=your_long_generated_secret_here
STRIPE_SECRET_KEY=sk_test_placeholder_for_testing
STRIPE_WEBHOOK_SECRET=
OPENAI_API_KEY=
```

### Important Formatting Rules:
- Each variable on its own line
- No spaces around the `=` sign
- No quotes around values
- Complete values (don't cut off secrets)

## Step 4: For Testing vs Production

### For Initial Testing:
- **Stripe**: Use `sk_test_placeholder_for_testing`
- **OpenAI**: Leave empty or use `placeholder_for_testing`

### When Ready for Real Integration:
- **Stripe**: Get real test keys from stripe.com dashboard
- **OpenAI**: Get API key from platform.openai.com

## Step 5: Verify Your Setup

Check that your secrets are properly configured:

```bash
# Make sure you're in your project directory first
cd your-project-name

# Verify the key variables are set
grep -E 'JWT_SECRET|STRIPE_SECRET_KEY' .env

# View entire file (be careful with sensitive data)
cat .env
```

## Common Issues & Solutions

### "No such file or directory"
- Make sure you're in the correct project directory
- Use `cd your-project-name` to navigate to your project
- Use `ls -la` to verify you can see the `.env` file

### Variables on same line
- Each environment variable must be on its own line
- Use `Enter` in nano to create new lines
- Format: `VARIABLE_NAME=value`

### Can't edit in nano
- Try alternative editors like `vim .env` or `code .env`
- Or use command line replacement:
```bash
JWT_SECRET=$(python3 -c "import secrets; print(secrets.token_urlsafe(64))")
sed -i "s/JWT_SECRET=REPLACE_ME/JWT_SECRET=$JWT_SECRET/" .env
```

## Security Notes

- Never commit your `.env` file to version control
- Keep your real API keys private
- Use placeholders for initial development
- The JWT secret should be long and random (64+ characters)

## Next Steps After .env Setup

Typically you'll move on to:
1. Install dependencies (`npm install` or `pip install -r requirements.txt`)
2. Set up database migrations
3. Start development server (`npm start` or similar)

Check your project's README.md for specific next steps.

---

**Remember**: Break complex setups into small steps. What looks overwhelming at first becomes manageable when taken piece by piece!