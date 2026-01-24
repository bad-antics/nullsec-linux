#!/usr/bin/env python3
"""
NullSec Promotion Automation Suite
Automated social media posting to build GitHub stars
"""

import os
import sys
import yaml
import json
import time
import random
import argparse
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

# Optional imports - install as needed
try:
    import praw  # Reddit
    REDDIT_AVAILABLE = True
except ImportError:
    REDDIT_AVAILABLE = False

try:
    import tweepy  # Twitter
    TWITTER_AVAILABLE = True
except ImportError:
    TWITTER_AVAILABLE = False

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False


class GitHubTracker:
    """Track GitHub repo statistics"""
    
    def __init__(self, username):
        self.username = username
        self.stats_file = Path(__file__).parent / "star_history.json"
    
    def get_repo_stats(self, repo):
        """Get current stats for a repo"""
        result = subprocess.run(
            ["gh", "api", f"repos/{self.username}/{repo}", 
             "--jq", "{stars: .stargazers_count, forks: .forks_count, watchers: .watchers_count}"],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
        return None
    
    def track_all(self, repos):
        """Track stats for all repos"""
        history = self._load_history()
        timestamp = datetime.now().isoformat()
        
        for repo in repos:
            stats = self.get_repo_stats(repo)
            if stats:
                if repo not in history:
                    history[repo] = []
                history[repo].append({
                    "timestamp": timestamp,
                    **stats
                })
                print(f"📊 {repo}: ⭐{stats['stars']} 🍴{stats['forks']}")
        
        self._save_history(history)
        return history
    
    def _load_history(self):
        if self.stats_file.exists():
            return json.loads(self.stats_file.read_text())
        return {}
    
    def _save_history(self, history):
        self.stats_file.write_text(json.dumps(history, indent=2))
    
    def show_progress(self, repos, target=50):
        """Show progress toward star goals"""
        print("\n" + "="*50)
        print("⭐ STAR PROGRESS TRACKER")
        print("="*50)
        
        for repo in repos:
            stats = self.get_repo_stats(repo)
            if stats:
                stars = stats['stars']
                progress = min(100, (stars / target) * 100)
                bar = "█" * int(progress / 5) + "░" * (20 - int(progress / 5))
                print(f"{repo:30} [{bar}] {stars}/{target} ⭐")
        print("="*50 + "\n")


class RedditPoster:
    """Automated Reddit posting"""
    
    def __init__(self, config):
        if not REDDIT_AVAILABLE:
            print("⚠️  Install praw: pip install praw")
            return
            
        self.reddit = praw.Reddit(
            client_id=config['client_id'],
            client_secret=config['client_secret'],
            username=config['username'],
            password=config['password'],
            user_agent=config['user_agent']
        )
        self.subreddits = config['subreddits']
    
    def post(self, subreddit, title, url=None, text=None):
        """Post to a subreddit"""
        try:
            sub = self.reddit.subreddit(subreddit)
            
            if url:
                submission = sub.submit(title, url=url)
            else:
                submission = sub.submit(title, selftext=text)
            
            print(f"✅ Posted to r/{subreddit}: {submission.url}")
            return submission
        except Exception as e:
            print(f"❌ Failed r/{subreddit}: {e}")
            return None
    
    def campaign(self, repo_url, title, text, categories=['security']):
        """Post to multiple subreddits with delays"""
        for category in categories:
            subs = self.subreddits.get(category, [])
            for sub in subs:
                self.post(sub, title, url=repo_url)
                # Delay to avoid rate limits
                delay = random.randint(600, 1800)  # 10-30 min
                print(f"⏳ Waiting {delay//60} minutes before next post...")
                time.sleep(delay)


class TwitterPoster:
    """Automated Twitter/X posting"""
    
    def __init__(self, config):
        if not TWITTER_AVAILABLE:
            print("⚠️  Install tweepy: pip install tweepy")
            return
            
        auth = tweepy.OAuthHandler(config['api_key'], config['api_secret'])
        auth.set_access_token(config['access_token'], config['access_secret'])
        self.api = tweepy.API(auth)
        self.client = tweepy.Client(
            consumer_key=config['api_key'],
            consumer_secret=config['api_secret'],
            access_token=config['access_token'],
            access_token_secret=config['access_secret']
        )
        self.hashtags = config['hashtags']
    
    def tweet(self, text, hashtags=True):
        """Post a tweet"""
        try:
            if hashtags:
                tags = " ".join(random.sample(self.hashtags, min(5, len(self.hashtags))))
                text = f"{text}\n\n{tags}"
            
            response = self.client.create_tweet(text=text[:280])
            print(f"✅ Tweeted: {text[:50]}...")
            return response
        except Exception as e:
            print(f"❌ Tweet failed: {e}")
            return None
    
    def thread(self, tweets):
        """Post a thread"""
        previous_id = None
        for tweet in tweets:
            try:
                response = self.client.create_tweet(
                    text=tweet[:280],
                    in_reply_to_tweet_id=previous_id
                )
                previous_id = response.data['id']
                print(f"✅ Thread tweet posted")
                time.sleep(2)
            except Exception as e:
                print(f"❌ Thread failed: {e}")
                break


class HackerNewsPoster:
    """Automated Hacker News submission"""
    
    def __init__(self, config):
        self.username = config.get('username')
        self.password = config.get('password')
        self.session = None
    
    def login(self):
        """Login to HN"""
        if not REQUESTS_AVAILABLE:
            print("⚠️  Install requests: pip install requests")
            return False
            
        import requests
        self.session = requests.Session()
        
        response = self.session.post(
            "https://news.ycombinator.com/login",
            data={
                "acct": self.username,
                "pw": self.password,
                "goto": "news"
            }
        )
        return "Bad login" not in response.text
    
    def submit(self, title, url):
        """Submit to HN"""
        if not self.session:
            if not self.login():
                print("❌ HN login failed")
                return None
        
        # Get CSRF token
        response = self.session.get("https://news.ycombinator.com/submit")
        # Parse fnid from form... (simplified)
        
        print(f"📰 HN submission requires manual CAPTCHA - open this URL:")
        print(f"   https://news.ycombinator.com/submitlink?u={url}&t={title}")
        return None


class DiscordNotifier:
    """Discord webhook notifications"""
    
    def __init__(self, webhook_url):
        self.webhook_url = webhook_url
    
    def notify(self, message, embeds=None):
        """Send Discord notification"""
        if not REQUESTS_AVAILABLE:
            return
            
        import requests
        
        data = {"content": message}
        if embeds:
            data["embeds"] = embeds
        
        try:
            requests.post(self.webhook_url, json=data)
            print("✅ Discord notification sent")
        except Exception as e:
            print(f"❌ Discord failed: {e}")


class PromotionCampaign:
    """Orchestrate full promotion campaign"""
    
    def __init__(self, config_path):
        with open(config_path) as f:
            self.config = yaml.safe_load(f)
        
        self.github = GitHubTracker(self.config['github']['username'])
        self.repos = self.config['github']['repos']
    
    def run_tracking(self):
        """Track current stats"""
        self.github.track_all(self.repos)
        self.github.show_progress(self.repos)
    
    def generate_posts(self, repo):
        """Generate social media posts for a repo"""
        templates = self.config.get('templates', {}).get(repo, {})
        repo_url = f"https://github.com/{self.config['github']['username']}/{repo}"
        
        posts = {
            'reddit_title': templates.get('title', f"{repo} - Check out this security tool"),
            'reddit_url': repo_url,
            'tweet': templates.get('short', f"🔒 Check out {repo} - open source security tool {repo_url}"),
            'hn_title': templates.get('title', f"{repo} - Open Source Security Tool"),
            'hn_url': repo_url
        }
        
        return posts
    
    def run_reddit_campaign(self, repo, categories=['security']):
        """Run Reddit posting campaign"""
        if not REDDIT_AVAILABLE:
            print("❌ Reddit not available. Install: pip install praw")
            return
        
        poster = RedditPoster(self.config['reddit'])
        posts = self.generate_posts(repo)
        poster.campaign(posts['reddit_url'], posts['reddit_title'], "", categories)
    
    def run_twitter_campaign(self, repo):
        """Run Twitter campaign"""
        if not TWITTER_AVAILABLE:
            print("❌ Twitter not available. Install: pip install tweepy")
            return
        
        poster = TwitterPoster(self.config['twitter'])
        posts = self.generate_posts(repo)
        poster.tweet(posts['tweet'])
    
    def dry_run(self, repo):
        """Show what would be posted without actually posting"""
        posts = self.generate_posts(repo)
        
        print("\n" + "="*50)
        print(f"🎯 DRY RUN: {repo}")
        print("="*50)
        
        print("\n📱 REDDIT POST:")
        print(f"   Title: {posts['reddit_title']}")
        print(f"   URL: {posts['reddit_url']}")
        print(f"   Subreddits: {self.config['reddit']['subreddits']}")
        
        print("\n🐦 TWITTER POST:")
        print(f"   {posts['tweet']}")
        
        print("\n📰 HACKER NEWS:")
        print(f"   Title: {posts['hn_title']}")
        print(f"   URL: {posts['hn_url']}")
        
        print("\n" + "="*50)


def main():
    parser = argparse.ArgumentParser(description="NullSec Promotion Automation")
    parser.add_argument('action', choices=['track', 'reddit', 'twitter', 'hn', 'all', 'dry-run'],
                       help="Action to perform")
    parser.add_argument('--repo', default='nullsec-linux', help="Repository to promote")
    parser.add_argument('--config', default='config.yaml', help="Config file path")
    
    args = parser.parse_args()
    
    config_path = Path(__file__).parent / args.config
    if not config_path.exists():
        print(f"❌ Config not found: {config_path}")
        print("   Copy config.yaml.example to config.yaml and fill in credentials")
        sys.exit(1)
    
    campaign = PromotionCampaign(config_path)
    
    if args.action == 'track':
        campaign.run_tracking()
    elif args.action == 'reddit':
        campaign.run_reddit_campaign(args.repo)
    elif args.action == 'twitter':
        campaign.run_twitter_campaign(args.repo)
    elif args.action == 'dry-run':
        campaign.dry_run(args.repo)
    elif args.action == 'all':
        campaign.dry_run(args.repo)
        print("\n⚠️  Full campaign requires manual confirmation")
        if input("Proceed? (yes/no): ").lower() == 'yes':
            campaign.run_twitter_campaign(args.repo)
            campaign.run_reddit_campaign(args.repo)


if __name__ == "__main__":
    main()
