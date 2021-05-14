#!/usr/bin/env python3
"""
Perform standup
"""
from datetime import datetime
from datetime import time
from datetime import timezone
from datetime import timedelta
import os
import sys

import requests


GITHUB_OWNER = 'stvstnfrd'
GITHUB_REPO = 'openedx-meta'


def post(url, data):
    """
    Perform an HTTP POST
    """
    return request_http(url, method='POST', data=data)


def get(url):
    """
    Perform an HTTP GET
    """
    return request_http(url)


def request_http(url, method=None, data=None):
    """
    Perform an HTTP request
    """
    method = method or 'GET'
    request_method = getattr(requests, method.lower())
    url = f"https://api.github.com/{url}"
    response = None
    try:
        data = {
            # 'key': 'value',
        }
        # params = {
        #     'q': 'requests+language:python',
        # }
        headers = {
            'Accept': 'application/vnd.github.inertia-preview+json',
        }
        token = os.environ.get('GITHUB_TOKEN')
        if token:
            headers.update({
                'Authorization': f"token {token}",
            })
        response = request_method(
            url,
            data=data,
            headers=headers,
            # params=params,
        )
    except requests.HTTPError as error:
        print(f'HTTP error occurred: {error}')
        raise
    except Exception as error:
        print(f'Other error occurred: {error}')
        raise
    else:
        pass
        # print('Success!')
    if not response:
        code = response.status_code
        message = response.json()['message']
        raise Exception(f"{code} {message}")
    data = response.json()
    return data


def main():
    """
    Handle the main script logic
    """
    display = 'standup'
    if len(sys.argv) > 1:
        display = sys.argv[1]
    board = Board(days=1)
    if display == 'standup':
        print(board.get_standup())
    elif display == 'sprint':
        print(board.get_retro())
    else:
        print('unsupported', display)
    # print(board.changelog)
    # board.standup()


def get_cards_done(column_id):
    """
    Fetch the listo of done cards
    """
    cards_done = get(f"projects/columns/{column_id}/cards")
    for card in cards_done:
        entry = Card.from_card(card)
        if not entry:
            continue
        yield entry


class Board:
    """
    Represent a Github Project board
    """

    def __init__(self, days=0):
        self.owner = GITHUB_OWNER
        self.repo = GITHUB_REPO
        self.days = days
        self.columns = {
            'done': {
                'id': 14068709,
                'cards': [],
                'authors': {},
            },
            'doing': {
                'id': 14068701,
                'cards': [],
                'authors': {},
            },
            'todo': {
                'id': 14068697,
                'cards': [],
                'authors': {},
            },
        }
        for key, column in self.columns.items():
            for card in get_cards_done(column['id']):
                self.columns[key]['cards'].append(card)
                if not card.author in self.columns[key]['authors']:
                    self.columns[key]['authors'][card.author] = []
                self.columns[key]['authors'][card.author].append(card)

    @property
    def changelog(self):
        """
        Generate a changelog
        """
        lines = []
        string = '\n'.join(lines)
        return string

    @property
    def is_standup_today(self):
        """
        Check if we should have standup today
        """
        standup_time = self.standup_time
        if standup_time.weekday() in (5,6):
            return False
        return True

    @property
    def standup_time(self):
        """
        Calculate the standup window stop time
        """
        do_yesterday = True
        now = datetime.now(timezone.utc)
        standup_at = time.fromisoformat('15:00:00')
        standup_today = datetime(
            now.year,
            now.month,
            now.day,
            standup_at.hour,
            standup_at.minute,
            standup_at.second,
            tzinfo=timezone.utc,
        )
        standup_tomorrow = standup_today + timedelta(days=1)
        standup_has_already_happened_today = now > standup_today
        if standup_has_already_happened_today and not do_yesterday:
            standup_next = standup_tomorrow
        else:
            standup_next = standup_today
        return standup_next

    @property
    def standup_time_window_open(self):
        """
        Calculate the standup window start time
        """
        period = timedelta(days=self.days)
        stop = self.standup_time - period
        return stop

    def standup(self):
        """
        Generate a standup report

        TODO: confirm/remove
        """
        title = self.title
        # body = str(self)
        labels = [
            'standup',
        ]
        data = {
            # 'assignees': self.participants,
            'body': self.body,
            'labels': labels,
            'title': title,
        }
        print('DATA', data)
        response = post(f"repos/{self.owner}/{self.repo}/issues", data=data)
        print('RESPONSE', response)
        return response

    @property
    def participants(self):
        """
        Fetch the list of participants on the board
        """
        assignees = set()
        for column in self.columns.values():
            for author in column['authors'].keys():
                assignees.add(author)
        return assignees

    @property
    def body(self):
        """
        Return the body, plaintext
        """
        text = str(self)
        return text

    @property
    def title(self):
        """
        Return the title, plaintext
        """
        timestamp = self.standup_time.date()
        text = f"standup: {timestamp}"
        return text

    @property
    def title_as_markdown(self):
        """
        Return the title, stylized as a markdown link
        """
        query = 'q=is%3Aissue+sort%3Aupdated-desc'
        url = f"https://github.com/{self.owner}/{self.repo}-meta/issues?{query}"
        text = f"[{self.title}]({url})"
        return text

    def __str__(self):
        return self.get_standup()

    def get_author_and_cards_filtered(self, column=None, filter_today_only=False):
        """
        Filter cards based on date
        """
        if column:
            column_keys = [column,]
        else:
            column_keys = ['todo', 'doing',]
        filtered_cards = {}
        for column_key in column_keys:
            for author, cards in self.columns[column_key]['authors'].items():
                for card in cards:
                    if filter_today_only and not card.is_in_timespan(
                            self.standup_time_window_open,
                            self.standup_time,
                    ):
                        continue
                    if author not in filtered_cards:
                        filtered_cards[author] = []
                    filtered_cards[author].append(card)
        return filtered_cards

    def get_standup(self):
        """
        Generate a standup changelog
        """
        return self.get_changelog(filter_today_only=True)

    def get_retro(self):
        """
        Generate a retro changelog
        """
        return self.get_changelog(filter_today_only=False)

    def get_changelog(self, filter_today_only=False):
        """
        Generate a changelog
        """
        if not self.is_standup_today:
            return ''
        assignees = ', '.join(self.participants)
        lines = [
            f"title: '{self.title}'",
            f"assignees: {assignees}",
            'labels: standup',
            '---',
        ]
        lines.append(f"# {self.title_as_markdown}")
        cards = self.get_author_and_cards_filtered()
        marker = ' '
        lines.append('\n## unreleased changes')
        for author, entries in cards.items():
            url = f"https://github.com/{self.owner}/{self.repo}/issues/assigned/{author}"
            lines.append(f"\n### [@{author}]({url})\n")
            for entry in entries:
                lines.append(f"- [{marker}] {entry.text_as_link}")
        cards = self.get_author_and_cards_filtered(
            column='done',
            filter_today_only=filter_today_only,
        )
        marker = 'x'
        column_id = self.columns['done']['id']
        url = (
            f"https://github.com/{self.owner}/{self.repo}/"
            f"projects/3#column-{column_id}"
        )
        lines.append(f"\n## [done]({url})")
        for author, entries in cards.items():
            url = f"https://github.com/{self.owner}/{self.repo}/issues/assigned/{author}"
            lines.append(f"\n### [@{author}]({url})\n")
            for entry in entries:
                lines.append(f"- [{marker}] {entry.text_as_link}")

        string = '\n'.join(lines)
        return string


class Card:
    """
    This is a (standup) entry
    """
    # pylint: disable=too-many-arguments
    def __init__(self, author, text, labels=None, url=None, updated_at=None):
        self.author = author
        self.text = text
        self.labels = labels or []
        self.url = url or ''
        self.updated_at = updated_at or None

    @property
    def text_as_link(self):
        """
        Return the body, stylized as a markdown link
        """
        text = self.text
        url = self.url
        text = f"[{text}]({url})"
        return text

    @property
    def author_as_link(self):
        """
        Return the author, stylized as a markdown link
        """
        text = self.author
        url = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/issues/assigned/{text}"
        text = f"[{text}]({url})"
        return text

    def __str__(self):
        string = f"{self.author}: {self.text}"
        return string

    def __repr__(self):
        string = f"{self.author}: {self.text}"
        return string

    def is_in_timespan(self, time_older, time_newer):
        """
        Check if card happened during the specified timespan
        """
        if self.updated_at < time_older:
            return False
        if self.updated_at > time_newer:
            return False
        return True

    @property
    def is_discussable(self):
        """
        Check if this card should be discussed
        """
        if self.text.startswith('discuss:'):
            return True
        if 'dicuss' in self.labels:
            return True
        return False

    @classmethod
    def from_card(cls, card):
        """
        Construct a card from a card payload
        """
        if card['archived']:
            return None
        text = card['note']
        author = card['creator']['login']
        updated_at = card['updated_at'][:-1]
        updated_at = datetime.fromisoformat(updated_at + '+00:00')
        if 'content_url' in card:
            url = card['content_url']
            issue_number = int(url.split('/')[-1])
            issue = get(f"repos/{GITHUB_OWNER}/{GITHUB_REPO}/issues/{issue_number}")
            entry = cls.from_issue(url, issue)
            return entry
        card_id = card['id']
        url = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/projects/3#card-{card_id}"
        instance = cls(author, text, url=url, updated_at=updated_at)
        return instance

    @classmethod
    def from_issue(cls, url, issue):
        """
        Construct a card from an issue payload
        """
        labels = [
            label['name']
            for label in issue['labels']
        ]
        author = issue['assignee']
        if author:
            author = author['login']
        if not author:
            author = issue['user']['login']
        updated_at = issue['closed_at'] or issue['updated_at'] or issue['created_at']
        updated_at = updated_at[:-1]
        updated_at = datetime.fromisoformat(updated_at + '+00:00')
        text = issue['title']
        url = issue['html_url']
        instance = cls(author, text, labels, url, updated_at=updated_at)
        return instance


if __name__ == '__main__':
    main()
