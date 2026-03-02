class ArticlesController < ApplicationController
  def index
    @articles = Article.published.recent

    if params[:category].present?
      @articles = @articles.by_category(params[:category])
      @current_category = params[:category]
    end

    @pagy, @articles = pagy(@articles, limit: 12)
  end

  def show
    @article = Article.friendly.find(params[:id])

    # Only show published articles to public
    unless @article.published? && @article.published_at <= Time.current
      redirect_to articles_path, alert: "Article not found"
      return
    end

    @related_articles = Article.published
      .where.not(id: @article.id)
      .where(category: @article.category)
      .recent
      .limit(3)

    # Fill with recent articles if not enough in same category
    if @related_articles.count < 3
      @related_articles = Article.published
        .where.not(id: @article.id)
        .recent
        .limit(3)
    end
  end
end
