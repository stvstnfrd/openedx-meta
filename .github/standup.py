#!/usr/bin/env python3
"""
Perform standup
"""
from datetime import datetime
from datetime import date
from datetime import timedelta
import os

import requests


GITHUB_OWNER = 'stvstnfrd'
GITHUB_REPO = 'openedx-meta'


def post(url, data):
    return request_http(url, method='POST', data=data)


def get(url):
    return request_http(url)


def request_http(url, method=None, data=None):
    method = method or 'GET'
    request_method = getattr(requests, method.lower())
    url = f"https://api.github.com/{url}"
    response = None
    try:
        data = {
            # 'key': 'value',
        }
        params = {
            'q': 'requests+language:python',
        }
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
    board = Board()
    print(board)
    # board.standup()


class Board:
    def __init__(self):
        self.owner = GITHUB_OWNER
        self.repo = GITHUB_REPO
        self.days = 3
        self.days_ahead = 1
        self.columns = {
            'done': {
                'id': 14068734,
                'cards': [],
                'authors': {},
            },
            'doing': {
                'id': 14068727,
                'cards': [],
                'authors': {},
            },
            'todo': {
                'id': 14068716,
                'cards': [],
                'authors': {},
            },
        }
        for key, column in self.columns.items():
            for card in self.get_cards_done(column['id']):
                self.columns[key]['cards'].append(card)
                if not card.author in self.columns[key]['authors']:
                    self.columns[key]['authors'][card.author] = []
                self.columns[key]['authors'][card.author].append(card)

    @property
    def standup_time(self):
        now = datetime.now()
        start = datetime(
            year=now.year,
            month=now.month,
            day=now.day,
            hour=12,
        ) + timedelta(days=self.days_ahead)
        return start

    @property
    def standup_time_window_open(self):
        period = timedelta(days=self.days)
        stop = self.standup_time - period
        return stop

    def get_cards_done(self, column_id):
        cards_done = get(f"projects/columns/{column_id}/cards")
        for card in cards_done:
            entry = Card.from_card(card)
            if not entry:
                continue
            if entry.is_in_timespan(self.standup_time_window_open, self.standup_time):
                yield entry

    def standup(self):
        title = self.title
        body = str(self)
        labels = [
            'standup',
        ]
        data = {
            # 'assignees': self.participants,
            'body': self.body,
            # 'labels': labels,
            'title': self.title,
        }
        print('DATA', data)
        response = post(f"repos/{self.owner}/{self.repo}/issues", data=data)
        print('RESPONSE', response)
        return response

    @property
    def participants(self):
        assignees = set()
        for column_id, column in self.columns.items():
            for author in column['authors'].keys():
                assignees.add(author)
        return assignees

    @property
    def body(self):
        text = str(self)
        return text

    @property
    def title(self):
        text = str(self.standup_time)
        return text

    @property
    def title_as_markdown(self):
        text = f"[standup: {self.title}](https://github.com/{self.owner}/{self.repo}-meta/issues?q=is%3Aissue+sort%3Aupdated-desc)"
        return text

    def __str__(self):
        assignees = ', '.join(self.assignees)
        lines = [
            '---',
            'title: {self.title}',
            'assignees: {assignees}',
            '---',
        ]
        lines.append(f"# {self.title_as_markdown}")
        for column in ('done', 'doing', 'todo'):
            if column == 'done':
                marker = 'x'
            else:
                marker = ' '
            cards = self.columns[column]['authors']
            column_id = self.columns[column]['id']
            lines.append(f"\n## [{column}](https://github.com/{self.owner}/{self.repo}/projects/3#column-{column_id})")
            for author, entries in cards.items():
                lines.append(f"\n### [@{author}](https://github.com/{self.owner}/{self.repo}/issues/assigned/{author})\n")
                for entry in entries:
                    lines.append(f"- [{marker}] {entry.text_as_link}")
            string = '\n'.join(lines)
        return string


class Card:
    """
    This is a (standup) entry
    """
    def __init__(self, author, text, labels=None, url=None, updated_at=None):
        self.author = author
        self.text = text
        self.labels = labels or []
        self.url = url or ''
        self.updated_at = updated_at or None

    @property
    def text_as_link(self):
        text = self.text
        url = self.url
        text = f"[{text}]({url})"
        return text

    @property
    def author_as_link(self):
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
        if self.updated_at < time_older:
            return False
        if self.updated_at > time_newer:
            return False
        return True

    @property
    def is_discussable(self):
        if self.text.startswith('discuss:'):
            return True
        if 'dicuss' in self.labels:
            return True
        return False

    @classmethod
    def from_card(cls, card):
        if card['archived']:
            return None
        text = card['note']
        author = card['creator']['login']
        updated_at = card['updated_at'][:-1]
        updated_at = datetime.fromisoformat(updated_at)
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
        labels = [
            label['name']
            for label in issue['labels']
        ]
        author = issue['assignee']
        if author:
            author = author['login']
        if not author:
            author = issue['user']['login']
        updated_at = issue['updated_at'][:-1]
        updated_at = datetime.fromisoformat(updated_at)
        text = issue['title']
        url = issue['html_url']
        instance = cls(author, text, labels, url, updated_at=updated_at)
        return instance


if __name__ == '__main__':
    main()
