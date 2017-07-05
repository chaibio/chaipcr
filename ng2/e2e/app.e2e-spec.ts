import { Ng2Page } from './app.po';

describe('ng2 App', () => {
  let page: Ng2Page;

  beforeEach(() => {
    page = new Ng2Page();
  });

  it('should display welcome message', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('Welcome to app!!');
  });
});
