import { Ng2Page } from './app.po';

describe('ng2 App', function() {
  let page: Ng2Page;

  beforeEach(() => {
    page = new Ng2Page();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
