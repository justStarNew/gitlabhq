require 'spec_helper'

describe ButtonHelper do
  describe 'http_clone_button' do
    let(:user) { create(:user) }
    let(:project) { build_stubbed(:project) }
    let(:has_tooltip_class) { 'has-tooltip' }

    def element
      element = helper.http_clone_button(project)

      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'with internal auth enabled' do
      context 'when user has a password' do
        it 'shows no tooltip' do
          expect(element.attr('class')).not_to include(has_tooltip_class)
        end
      end

      context 'when user has password automatically set' do
        let(:user) { create(:user, password_automatically_set: true) }

        it 'shows the password text on the dropdown' do
          expect(element.children.length).to eq(2)
          expect(element.children[1].name).to eq('span')
          expect(element.children[1].children[0].text).to eq('Set a password on your account to pull or push via HTTP.')
        end
      end
    end

    context 'with internal auth disabled' do
      before do
        stub_application_setting(password_authentication_enabled_for_git?: false)
      end

      context 'when user has no personal access tokens' do
        it 'has a personal access token tooltip ' do
          expect(element.children.length).to eq(2)
          expect(element.children[1].name).to eq('span')
          expect(element.children[1].children[0].text).to eq('Create a personal access token on your account to pull or push via HTTP.')
        end
      end

      context 'when user has a personal access token' do
        it 'shows no tooltip' do
          create(:personal_access_token, user: user)

          expect(element.attr('class')).not_to include(has_tooltip_class)
        end
      end
    end

    context 'when user is ldap user' do
      let(:user) { create(:omniauth_user, password_automatically_set: true) }

      it 'shows no tooltip' do
        expect(element.attr('class')).not_to include(has_tooltip_class)
      end
    end
  end

  describe 'clipboard_button' do
    let(:user) { create(:user) }
    let(:project) { build_stubbed(:project) }

    def element(data = {})
      element = helper.clipboard_button(data)
      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'with default options' do
      context 'when no `text` attribute is not provided' do
        it 'shows copy to clipboard button with default configuration and no text set to copy' do
          expect(element.attr('class')).to eq('btn btn-clipboard btn-transparent')
          expect(element.attr('type')).to eq('button')
          expect(element.attr('aria-label')).to eq('Copy to clipboard')
          expect(element.attr('data-toggle')).to eq('tooltip')
          expect(element.attr('data-placement')).to eq('bottom')
          expect(element.attr('data-container')).to eq('body')
          expect(element.attr('data-clipboard-text')).to eq(nil)
          expect(element.inner_text).to eq("")

          expect(element).to have_selector('.fa.fa-clipboard')
        end
      end

      context 'when `text` attribute is provided' do
        it 'shows copy to clipboard button with provided `text` to copy' do
          expect(element(text: 'Hello World!').attr('data-clipboard-text')).to eq('Hello World!')
        end
      end

      context 'when `title` attribute is provided' do
        it 'shows copy to clipboard button with provided `title` as tooltip' do
          expect(element(title: 'Copy to my clipboard!').attr('aria-label')).to eq('Copy to my clipboard!')
        end
      end
    end

    context 'with `button_text` attribute provided' do
      it 'shows copy to clipboard button with provided `button_text` as button label' do
        expect(element(button_text: 'Copy text').inner_text).to eq('Copy text')
      end
    end

    context 'with `hide_tooltip` attribute provided' do
      it 'shows copy to clipboard button without tooltip support' do
        expect(element(hide_tooltip: true).attr('data-placement')).to eq(nil)
        expect(element(hide_tooltip: true).attr('data-toggle')).to eq(nil)
        expect(element(hide_tooltip: true).attr('data-container')).to eq(nil)
      end
    end

    context 'with `hide_button_icon` attribute provided' do
      it 'shows copy to clipboard button without tooltip support' do
        expect(element(hide_button_icon: true)).not_to have_selector('.fa.fa-clipboard')
      end
    end
  end
end
