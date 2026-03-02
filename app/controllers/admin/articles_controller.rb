module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

    def index
      @articles = Article.order(created_at: :desc)

      if params[:status] == "published"
        @articles = @articles.published
      elsif params[:status] == "draft"
        @articles = @articles.draft
      end

      @pagy, @articles = pagy(@articles, limit: 20)
    end

    def show
    end

    def new
      @article = Article.new(author: "Bob Idell")
    end

    def create
      @article = Article.new(article_params)

      if @article.save
        redirect_to admin_article_path(@article), notice: "Article created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @article.update(article_params)
        redirect_to admin_article_path(@article), notice: "Article updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Article deleted."
    end

    def publish
      @article.update(published: true, published_at: Time.current)
      redirect_to admin_article_path(@article), notice: "Article published!"
    end

    def unpublish
      @article.update(published: false)
      redirect_to admin_article_path(@article), notice: "Article unpublished."
    end

    private

    def set_article
      @article = Article.friendly.find(params[:id])
    end

    def article_params
      params.require(:article).permit(
        :title,
        :content,
        :meta_description,
        :excerpt,
        :featured_image_url,
        :author,
        :category,
        :tags,
        :published,
        :published_at
      )
    end
  end
end
