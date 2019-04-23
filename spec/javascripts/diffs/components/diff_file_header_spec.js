import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { mountComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
const discussionFixture = 'merge_requests/diff_discussion.json';

  const diffDiscussionMock = getJSONFixture(discussionFixture)[0];
    const diffFile = convertObjectPropsToCamelCase(diffDiscussionMock.diff_file, { deep: true });
      diffFile,
          submoduleLink: 'link://to/submodule',
          submoduleTreeUrl: 'some://tree/url',
        expect(vm.titleLink).toBe(props.diffFile.submoduleTreeUrl);
          submoduleTreeUrl: null,
        expect(vm.titleLink).toBe(props.diffFile.submoduleLink);
          filePath: 'path/to/file',
        expect(vm.filePath).toBe(props.diffFile.filePath);
          `${props.diffFile.filePath} @ ${props.diffFile.blob.id.substr(0, 8)}`,
        props.diffFile.fileHash = 'some hash';
        props.diffFile.fileHash = null;
          storedExternally: true,
          externalStorage: 'lfs',
        props.diffFile.storedExternally = false;
        props.diffFile.externalStorage = 'not lfs';
        props.diffFile.contentSha = dummySha;
        props.diffFile.diffRefs.baseSha = dummySha;
        props.diffFile.renamedFile = false;
        expect(filePaths()[0]).toHaveText(props.diffFile.filePath);
        props.diffFile.renamedFile = false;
        props.diffFile.deletedFile = true;
        expect(filePaths()[0]).toHaveText(`${props.diffFile.filePath} deleted`);
        props.diffFile.renamedFile = true;
        expect(filePaths()[0]).toHaveText(props.diffFile.oldPath);
        expect(filePaths()[1]).toHaveText(props.diffFile.newPath);
      expect(button.dataset.clipboardText).toBe(
        '{"text":"files/ruby/popen.rb","gfm":"`files/ruby/popen.rb`"}',
      );
        props.diffFile.modeChanged = true;
        expect(fileMode).toContainText(props.diffFile.aMode);
        expect(fileMode).toContainText(props.diffFile.bMode);
        props.diffFile.modeChanged = false;
          storedExternally: true,
          externalStorage: 'lfs',
        props.diffFile.storedExternally = false;
        props.diffFile.editPath = '/';
        expect(vm.$el.querySelector('.js-edit-blob')).toContainText('Edit');
        props.diffFile.deletedFile = true;
        props.diffFile.editPath = '/';
        props.diffFile.editPath = '';
          props.diffFile.externalUrl = url;
          props.diffFile.formattedExternalUrl = title;
          props.diffFile.externalUrl = '';
          props.diffFile.formattedExternalUrl = title;
          readableText: true,
        propsCopy.diffFile.deletedFile = true;
            readableText: true,
          propsCopy.diffFile.deletedFile = true;
          const discussionGetter = () => [diffDiscussionMock];