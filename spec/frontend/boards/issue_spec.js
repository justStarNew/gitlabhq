/* global ListIssue */

import '~/boards/models/label';
import '~/boards/models/assignee';
import '~/boards/models/issue';
import '~/boards/models/list';
import boardsStore from '~/boards/stores/boards_store';
import { setMockEndpoints, mockIssue } from './mock_data';

describe('Issue model', () => {
  let issue;

  beforeEach(() => {
    setMockEndpoints();
    boardsStore.create();

    issue = new ListIssue(mockIssue);
  });

  it('has label', () => {
    expect(issue.labels.length).toBe(1);
  });

  it('add new label', () => {
    issue.addLabel({
      id: 2,
      title: 'bug',
      color: 'blue',
      description: 'bugs!',
    });

    expect(issue.labels.length).toBe(2);
  });

  it('does not add label if label id exists', () => {
    issue.addLabel({
      id: 1,
      title: 'test 2',
      color: 'blue',
      description: 'testing',
    });

    expect(issue.labels.length).toBe(1);
    expect(issue.labels[0].color).toBe('red');
  });

  it('adds other label with same title', () => {
    issue.addLabel({
      id: 2,
      title: 'test',
      color: 'blue',
      description: 'other test',
    });

    expect(issue.labels.length).toBe(2);
  });

  it('finds label', () => {
    const label = issue.findLabel(issue.labels[0]);

    expect(label).toBeDefined();
  });

  it('removes label', () => {
    const label = issue.findLabel(issue.labels[0]);
    issue.removeLabel(label);

    expect(issue.labels.length).toBe(0);
  });

  it('removes multiple labels', () => {
    issue.addLabel({
      id: 2,
      title: 'bug',
      color: 'blue',
      description: 'bugs!',
    });

    expect(issue.labels.length).toBe(2);

    issue.removeLabels([issue.labels[0], issue.labels[1]]);

    expect(issue.labels.length).toBe(0);
  });

  it('adds assignee', () => {
    issue.addAssignee({
      id: 2,
      name: 'Bruce Wayne',
      username: 'batman',
      avatar_url: 'http://batman',
    });

    expect(issue.assignees.length).toBe(2);
  });

  it('finds assignee', () => {
    const assignee = issue.findAssignee(issue.assignees[0]);

    expect(assignee).toBeDefined();
  });

  it('removes assignee', () => {
    const assignee = issue.findAssignee(issue.assignees[0]);
    issue.removeAssignee(assignee);

    expect(issue.assignees.length).toBe(0);
  });

  it('removes all assignees', () => {
    issue.removeAllAssignees();

    expect(issue.assignees.length).toBe(0);
  });

  it('sets position to infinity if no position is stored', () => {
    expect(issue.position).toBe(Infinity);
  });

  it('sets position', () => {
    const relativePositionIssue = new ListIssue({
      title: 'Testing',
      iid: 1,
      confidential: false,
      relative_position: 1,
      labels: [],
      assignees: [],
    });

    expect(relativePositionIssue.position).toBe(1);
  });

  it('updates data', () => {
    issue.updateData({ subscribed: true });

    expect(issue.subscribed).toBe(true);
  });

  it('sets fetching state', () => {
    expect(issue.isFetching.subscriptions).toBe(true);

    issue.setFetchingState('subscriptions', false);

    expect(issue.isFetching.subscriptions).toBe(false);
  });

  it('sets loading state', () => {
    issue.setLoadingState('foo', true);

    expect(issue.isLoading.foo).toBe(true);
  });

  describe('update', () => {
    it('passes update to boardsStore', () => {
      jest.spyOn(boardsStore, 'updateIssue').mockImplementation();

      issue.update();

      expect(boardsStore.updateIssue).toHaveBeenCalledWith(issue);
    });
  });
});
