require 'spec_helper'

describe Issues::MoveService, services: true do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:title) { 'Some issue' }
  let(:description) { 'Some issue description' }
  let(:old_project) { create(:project) }
  let(:new_project) { create(:project) }
  let(:issue_params) { old_issue.serializable_hash }

  let(:old_issue) do
    create(:issue, title: title, description: description,
                   project: old_project, author: author)
  end

  let(:move_service) do
    described_class.new(old_project, user, issue_params, old_issue, new_project_id)
  end

  shared_context 'issue move requested' do
    let(:new_project_id) { new_project.id }
  end

  shared_context 'user can move issue' do
    before do
      old_project.team << [user, :reporter]
      new_project.team << [user, :reporter]
    end
  end

  context 'issue movable' do
    include_context 'issue move requested'
    include_context 'user can move issue'

    describe '#move?' do
      subject { move_service.move? }
      it { is_expected.to be_truthy }
    end

    describe '#execute' do
      shared_context 'issue move executed' do
        let!(:new_issue) { move_service.execute }
      end

      context 'generic issue' do
        include_context 'issue move executed'

        it 'creates a new issue in a new project' do
          expect(new_issue.project).to eq new_project
        end

        it 'rewrites issue title' do
          expect(new_issue.title).to eq title
        end

        it 'rewrites issue description' do
          expect(new_issue.description).to eq description
        end

        it 'adds system note to old issue at the end' do
          expect(old_issue.notes.last.note).to match /^Moved to/
        end

        it 'adds system note to new issue at the end' do
          expect(new_issue.notes.last.note).to match /^Moved from/
        end

        it 'closes old issue' do
          expect(old_issue.closed?).to be true
        end

        it 'persists new issue' do
          expect(new_issue.persisted?).to be true
        end

        it 'persists all changes' do
          expect(old_issue.changed?).to be false
          expect(new_issue.changed?).to be false
        end

        it 'preserves author' do
          expect(new_issue.author).to eq author
        end

        it 'removes data that is invalid in new context' do
          expect(new_issue.milestone).to be_nil
          expect(new_issue.labels).to be_empty
        end

        it 'creates a new internal id for issue' do
          expect(new_issue.iid).to be 1
        end
      end

      context 'issue with notes' do
        context 'notes without references' do
          let(:notes_params) do
            [{ system: false, note: 'Some comment 1' },
             { system: true, note: 'Some system note' },
             { system: false, note: 'Some comment 2' }]
          end

          let(:notes_contents) { notes_params.map { |n| n[:note] } }

          before do
            note_params = { noteable: old_issue, project: old_project, author: author }
            notes_params.each do |note|
              create(:note, note_params.merge(note))
            end
          end

          include_context 'issue move executed'

          let(:all_notes) { new_issue.notes.order('id ASC') }
          let(:system_notes) { all_notes.system }
          let(:user_notes) { all_notes.user }

          it 'rewrites existing notes in valid order' do
            expect(all_notes.pluck(:note).first(3)).to eq notes_contents
          end

          it 'adds a system note about move after rewritten notes' do
            expect(system_notes.last.note).to match /^Moved from/
          end

          it 'preserves orignal author of comment' do
            expect(user_notes.pluck(:author_id)).to all(eq(author.id))
          end
        end

        context 'notes with references' do
          before do
            create(:merge_request, source_project: old_project)
            create(:note, noteable: old_issue, project: old_project, author: author,
                          note: 'Note with reference to merge request !1')
          end

          include_context 'issue move executed'
          let(:new_note) { new_issue.notes.first }

          it 'rewrites references using a cross reference to old project' do
            expect(new_note.note)
              .to eq "Note with reference to merge request #{old_project.to_reference}!1"
          end
        end
      end

      describe 'rewritting references' do
        include_context 'issue move executed'

        context 'issue reference' do
          let(:another_issue) { create(:issue, project: old_project) }
          let(:description) { "Some description #{another_issue.to_reference}" }

          it 'rewrites referenced issues creating cross project reference' do
            expect(new_issue.description)
              .to eq "Some description #{old_project.to_reference}#{another_issue.to_reference}"
          end
        end
      end
    end
  end

  context 'moving to same project' do
    let(:new_project) { old_project }

    include_context 'issue move requested'
    include_context 'user can move issue'

    it 'raises error' do
      expect { move_service }
        .to raise_error(StandardError, /Cannot move issue/)
    end
  end

  context 'issue move not requested' do
    let(:new_project_id) { nil }

    describe '#move?' do
      subject { move_service.move? }

      context 'user do not have permissions to move issue' do
        it { is_expected.to be_falsey }
      end

      context 'user has permissions to move issue' do
        include_context 'user can move issue'
        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'move permissions' do
    include_context 'issue move requested'

    describe '#move?' do
      subject { move_service.move? }

      context 'user is reporter in both projects' do
        include_context 'user can move issue'
        it { is_expected.to be_truthy }
      end

      context 'user is reporter only in new project' do
        before { new_project.team << [user, :reporter] }
        it { is_expected.to be_falsey }
      end

      context 'user is reporter only in old project' do
        before { old_project.team << [user, :reporter] }
        it { is_expected.to be_falsey }
      end

      context 'user is reporter in one project and guest in another' do
        before do
          new_project.team << [user, :guest]
          old_project.team << [user, :reporter]
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
